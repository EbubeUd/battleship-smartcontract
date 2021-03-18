
 // SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;
import "./IDataStorageSchema.sol";

interface IGameLogic is IDataStorageSchema
{
    
    
    function getPositionsOccupiedByShips( ShipType[5] memory _ship, uint8[5] memory _startingPositions, AxisType[5] memory _axis) external view returns (uint8[] memory);
    function getShipTypeFromIndex(uint8 _index) external view returns (ShipType);
    function getShipInxesFromShipType(ShipType _shipType) external view returns (uint8[] memory);
    function getOrderedpositionAndAxis(bytes memory positions) external pure returns(uint8[] memory, AxisType[5] memory);
    function CheckEqualArray(uint8[] memory _arr1, uint8[] memory _arr2) external pure returns (bool);
}