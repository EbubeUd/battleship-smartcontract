 // SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;
import "./lib/ReentrancyGuard.sol";
import "./interfaces/IDataStorageSchema.sol";
import "./lib/HelperFunctions.sol";
import "./lib/merkletree/MerkleProof.sol";


contract GameLogic is ReentrancyGuard, IDataStorageSchema
{
     
     mapping(ShipType => uint8) shipSize;
     mapping (ShipType => uint8[]) shipIndexes;
     mapping (uint8 => ShipType) shipFromIndex;
     uint8 sumOfShipSizes;
     uint8 gridDimensionX;
     uint8 gridDimensionY;
     uint8 gridSquare;
     
     HelperFunctions helperFunction;
     
     
     
     constructor() 
     {
         gridDimensionX = 10;
         gridDimensionY = 10;
         sumOfShipSizes = 17;
         
         for(uint8 i = 0; i < sumOfShipSizes; i++)
         {
             ShipType shipType;
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
         
         gridSquare = gridDimensionX * gridDimensionY;
         helperFunction = new HelperFunctions();
     }
     
     function getPositionsOccupiedByShips( ShipType[5] memory _ship, uint8[5] memory _startingPositions, AxisType[5] memory _axis) public view returns (uint8[] memory)
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
     
     function getShipTypeFromIndex(uint8 _index) public view returns (ShipType)
     {
         return shipFromIndex[_index];
     }
     
     function getShipInxesFromShipType(ShipType _shipType) public view returns (uint8[] memory)
     {
         return shipIndexes[_shipType];
     }
     
  
     function getStartingpositionAndAxis(bytes32[] memory positions) public pure returns(uint8[] memory, AxisType[5] memory)
     {
        uint8[5] memory startingPositions = [0, 0 , 0 , 0, 0];
        AxisType[5] memory axis;
        uint8[] memory orderedPositions = new uint8[](17);
        bytes32 position;
        uint destroyerCount = 0;
        uint submarineCount = 0;
        uint cruiserCount = 0;
        uint battleshipCount = 0;
        uint carrierCount = 0;
        
         for(uint8 i = 0; i < positions.length; i++)
         {
             position = positions[i];
             byte shipIndex = position[0];
             byte shipAxis = position[1];
             uint8 pIndex = i+1;
             
             
             //Destroyer
             if(shipIndex == '1') 
             {
                 if(startingPositions[0] == 0)
                 {
                    startingPositions[0] = pIndex;
                    axis[0] = shipAxis == '0' ? AxisType.X : AxisType.Y;
                 }
                 orderedPositions[destroyerCount -1] = pIndex;
             }
             
             //Subrine
             if(shipIndex == '2')
             {
                 if(startingPositions[1] == 0)
                 {
                    startingPositions[1] = pIndex;
                    axis[1] = shipAxis == '0' ? AxisType.X : AxisType.Y;
                 }
                 orderedPositions[submarineCount -1] = pIndex;

             }
             
             //Cruiser
             if(shipIndex == '3') 
             {
                 if(startingPositions[2] == 0)
                 {
                    startingPositions[2] = pIndex;
                    axis[2] = shipAxis == '0' ? AxisType.X : AxisType.Y;
                 }
                 orderedPositions[cruiserCount -1] = pIndex;
             }
             
             //Battleship
             if(shipIndex == '4') 
             {
                 if(startingPositions[3] == 0)
                 {
                    startingPositions[3] = pIndex;
                    axis[3] = shipAxis == '0' ? AxisType.X : AxisType.Y;
                 }
                 orderedPositions[battleshipCount -1] = pIndex;
             }
             
             //Carrier
             if(shipIndex == '5') 
             {
                 if(startingPositions[4] == 0)
                 {
                    startingPositions[4] = pIndex;
                    axis[4] = shipAxis == '0' ? AxisType.X : AxisType.Y; 
                 }
                 orderedPositions[carrierCount -1] = pIndex;
             }
             
             
         }
         

         return (orderedPositions, axis);
     }
     
     
    //Check that two arrays are equal
    function CheckEqualArray(uint8[] memory _arr1, uint8[] memory _arr2) public pure returns (bool)
    {
        if(_arr1.length != _arr2.length) return false;
        for(uint i = 0; i < _arr1.length; i++)
        {
            if(_arr1[i] != _arr2[i]) return false;
        }
        return true;
    }
    

     

 }