 // SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;
import "./lib/ReentrancyGuard.sol";
import "./interfaces/IDataStorageSchema.sol";
import "./lib/merkletree/MerkleProof.sol";


contract GameLogic is ReentrancyGuard, IDataStorageSchema
{
     
     mapping(ShipType => uint8) shipSize;
     mapping (ShipType => uint8[]) shipIndexes;
     mapping (uint8 => ShipType) shipFromIndex;
     mapping (string => ShipPosition) shipPositionMapping;
     uint8 sumOfShipSizes;
     uint8 gridDimensionX;
     uint8 gridDimensionY;
     uint8 gridSquare;
     
     constructor() 
     {
         gridDimensionX = 10;
         gridDimensionY = 10;
         sumOfShipSizes = 17;
         
         for(uint8 i = 0; i < sumOfShipSizes; i++)
         {
             ShipType shipType = ShipType.None;
             if(i == 0 || i == 1)
             {
                 shipType = ShipType.Destroyer;
                 shipIndexes[ShipType.Destroyer].push(i);
             }
             else if(i > 1 && i < 5)
             {
                 shipType = ShipType.Submarine;
                 shipIndexes[ShipType.Submarine].push(i);
             }
             else if(i > 4 && i < 8)
             {
                 shipType = ShipType.Cruiser;
                 shipIndexes[ShipType.Cruiser].push(i);

             }
             else if(i > 7 && i < 12)
             {
                 shipType = ShipType.Battleship;
                 shipIndexes[ShipType.Battleship].push(i);

             }
             else
             {
                 shipType = ShipType.Carrier;
                 shipIndexes[ShipType.Carrier].push(i);
             }
             
             shipFromIndex[i] = shipType;
         }
         

         shipSize[ShipType.Destroyer] = 2;
         shipSize[ShipType.Submarine] = 3;
         shipSize[ShipType.Cruiser] = 3;
         shipSize[ShipType.Battleship] = 4;
         shipSize[ShipType.Carrier] = 5;

         shipPositionMapping["11"] = ShipPosition(ShipType.Destroyer,AxisType.X);
         shipPositionMapping["12"] = ShipPosition(ShipType.Destroyer, AxisType.Y);
         shipPositionMapping["21"] = ShipPosition(ShipType.Submarine, AxisType.X);
         shipPositionMapping["22"] = ShipPosition(ShipType.Submarine, AxisType.Y);
         shipPositionMapping["31"] = ShipPosition(ShipType.Cruiser, AxisType.X);
         shipPositionMapping["32"] = ShipPosition(ShipType.Cruiser, AxisType.Y);
         shipPositionMapping["41"] = ShipPosition(ShipType.Battleship, AxisType.X);
         shipPositionMapping["42"] = ShipPosition(ShipType.Battleship, AxisType.Y);
         shipPositionMapping["51"] = ShipPosition(ShipType.Carrier, AxisType.X);
         shipPositionMapping["52"] = ShipPosition(ShipType.Carrier, AxisType.Y);
         
         gridSquare = gridDimensionX * gridDimensionY;
     }
     
     function getPositionsOccupiedByShips( ShipType[5] memory _ship, uint8[5] memory _startingPositions, AxisType[5] memory _axis) external view returns (uint8[] memory)
     {
         uint8[] memory combinedShipPositions = new uint8[](sumOfShipSizes);
         uint8[100] memory locationStatus;
         uint8 combinedShipPositionIndex = 0;
         for(uint8 i = 0; i < _startingPositions.length; i++)
         {
            uint8 sizeOfShip = shipSize[_ship[i]];
            uint8 startingPosition = _startingPositions[i];
            AxisType axis = _axis[i];
            

            uint8 incrementer = axis == AxisType.X ? 1 : gridDimensionX;
            uint8 maxTile = startingPosition + (incrementer * (sizeOfShip-1));
            
            
            require (maxTile <= gridSquare, "Ship can not be placed outside the grid");
            
            if(axis == AxisType.X)
            {
                uint lowerLimitFactor = (startingPosition - (startingPosition % gridDimensionX)) / gridDimensionX;
                uint upperLimitFactor = (maxTile - (maxTile % gridDimensionX)) / gridDimensionX;
                require (lowerLimitFactor == upperLimitFactor, "Invalid Ship placement");
            }

            
            //Fill in the positions
            for(uint8 j = 0; j < sizeOfShip; j++)
            {
                uint8 position = startingPosition + (j * incrementer);
                require(locationStatus[position] == 0, "Ships can not overlap");
                locationStatus[position] = 1;
                combinedShipPositions[combinedShipPositionIndex] = position;
                combinedShipPositionIndex++;
            }
            
         }
         
         return combinedShipPositions;
     }
     
     function getShipTypeFromIndex(uint8 _index) external view returns (ShipType)
     {
         if(_index <  0 || _index > 16) return ShipType.None;
         return shipFromIndex[_index];
     }
     
     function getShipInxesFromShipType(ShipType _shipType) external view returns (uint8[] memory)
     {
         return shipIndexes[_shipType];
     }
     
  
     function getOrderedpositionAndAxis(string memory positions) external view returns(uint16[] memory, AxisType[5] memory)
     {
        AxisType[5] memory axis = [AxisType.None, AxisType.None, AxisType.None, AxisType.None, AxisType.None];
        uint16[] memory orderedPositions = new uint16[](17);



        uint8 destroyerCount = 0;
        uint8 submarineCount = 2;
        uint8 cruiserCount = 5;
        uint8 battleshipCount = 8;
        uint8 carrierCount = 12;

        ShipPosition memory shipPosition = ShipPosition(ShipType.None, AxisType.None);
        string memory shipPositionKey = "";

         for(uint16 i = 0; i < 400; i+=4)
         {

             shipPositionKey = getSlice(i+1, i+2, positions);
             shipPosition = shipPositionMapping[shipPositionKey];

             
             
             //Destroyer
             if(shipPosition.ship == ShipType.Destroyer) 
             {
                 if(axis[0] == AxisType.None) axis[0] = shipPosition.axis;
                 orderedPositions[destroyerCount] = (i/4) + 1;
                destroyerCount++;
             }
             
             //Submarine
             if(shipPosition.ship == ShipType.Submarine)
             {
                if(axis[1] == AxisType.None) axis[1] = shipPosition.axis;
                orderedPositions[submarineCount] = (i/4) + 1;
                submarineCount++;
             }
             
             //Cruiser
             if(shipPosition.ship == ShipType.Cruiser)
             {
                if(axis[2] == AxisType.None) axis[2] = shipPosition.axis;
                orderedPositions[cruiserCount] = (i/4) + 1;
                cruiserCount++;
             }
             
             //Battleship
             if(shipPosition.ship == ShipType.Battleship)
             {
                if(axis[3] == AxisType.None) axis[3] = shipPosition.axis;
                orderedPositions[battleshipCount] = (i/4) + 1;
                battleshipCount++;
             }
             
             //Carrier
             if(shipPosition.ship == ShipType.Carrier)
             {
                if(axis[4] == AxisType.None) axis[4] = shipPosition.axis;
                orderedPositions[carrierCount] = (i/4) + 1;
                carrierCount++;
             }
             
             
         }
         

         return (orderedPositions, axis);
     }
     
     
    //Check that two arrays are equal
    function CheckEqualArray(uint8[] memory _arr1, uint8[] memory _arr2) external pure returns (bool)
    {
        if(_arr1.length != _arr2.length) return false;
        for(uint i = 0; i < _arr1.length; i++)
        {
            if(_arr1[i] != _arr2[i]) return false;
        }
        return true;
    }
    


    function stringToBytes32(string memory source) external pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
    }
    

    
    function getBytes32FromBytes(bytes memory value, uint index) public pure returns(bytes32)
    {
        bytes32 el;
        uint position = 32 * (index + 1);
        //Require That the length of the bytes covers the position to be read from
        require(value.length >= position, "The value requested is not within the range of the bytes");
       assembly {
        el := mload(add(value, position))
        }
        
        return el;
    }

    function getSliceOfBytesArray(bytes memory _bytesArray, uint16 _indexStart, uint16 _indexStop) external pure returns(bytes memory)
    {
        bytes memory value = new bytes(_indexStop-_indexStart+1);
        uint position = 32 * (_indexStop + 1);
        require(_bytesArray.length >= position, "The value requested is not within the range of the bytes");
        
        for(uint i=0;i<=_indexStart-_indexStart;i++){
            value[i] = _bytesArray[i+_indexStart-1];
        }

        return value;
    }
    
    //Gets a slice from a string
    function getSlice(uint256 begin, uint256 end, string memory text) public pure returns (string memory) {
        bytes memory a = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){
            a[i] = bytes(text)[i+begin-1];
        }
        return string(a);
    }

    function getShipPosition(string memory positionKey) external view returns (ShipPosition memory)
    {
        return shipPositionMapping[positionKey];
    }
    
    

     

 }