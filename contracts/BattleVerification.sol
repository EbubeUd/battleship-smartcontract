// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;

import "./lib/ReentrancyGuard.sol";
import "./interfaces/IDataStorage.sol";
import "./interfaces/IDataStorageSchema.sol";
import "./interfaces/IGameLogic.sol";
import "./lib/biconomy/BasicMetaTransaction.sol";
import "./lib/merkletree/MerkleProof.sol";

 /**
 * @title Battleship
 * @dev Store & retrieve value in a variable
 */

 contract BattleVerification is ReentrancyGuard, BasicMetaTransaction, IDataStorageSchema, MerkleProof {

   IDataStorage dataStorageContract;
    MerkleProof merkleProof;
    IGameLogic gameLogic;
    address payable owner;

    constructor(address _dataStorageContract, address _gameLogicAddress) 
    {
        //Set the shipSizes
        dataStorageContract = IDataStorage(_dataStorageContract);
        merkleProof = new MerkleProof();
        owner = payable(msgSender());
        gameLogic = IGameLogic(_gameLogicAddress);
    }



    event MerkleTreeLeafVerificationComplete(uint _battleId, address _winnerAddress, bool _verificationResult);
    event ShipPositionVerificationComplete(uint _battleId, address _winnerAddress, bool _verificationResult);
    
    
    
    function verifyMerkleTreeLeafs(uint _battleId, string memory _leafs, bytes[] memory _proofs) public  returns (bool)
    {
        //Get the required data
        BattleModel memory battle = dataStorageContract.getBattle(_battleId);
        address playerAddress = msgSender();
        bytes32 root = dataStorageContract.getMerkleTreeRoot(_battleId, playerAddress);

        
        //Requirements for process to continue
        require(battle.isCompleted, "Battle is not yet completed");
        require(battle.winner == playerAddress, "Only the suspected winner of the battle can access this function");
        require(!battle.leafVerificationPassed, "Leaf verification has already been passed");
        bool isTreeValid = merkleProof.checkProofsOrdered(_proofs, root, _leafs);
        MerkleTreeLeafVerificationComplete(_battleId, playerAddress, isTreeValid);
        
        if(isTreeValid)
        {
            battle.leafVerificationPassed = true;
            dataStorageContract.updateBattle(_battleId, battle);
            dataStorageContract.setRevealedLeafs(_battleId, playerAddress, _leafs);
        }
        
        return isTreeValid;
    }
    
    
    function verifyShipPositions(uint _battleId) public returns (bool)
    {
        BattleModel memory battle = dataStorageContract.getBattle(_battleId);
        address playerAddress = msgSender();
        string memory leafs = dataStorageContract.getRevealedLeafs(_battleId, playerAddress);
        
        //Requirements for process to continue
        require(battle.isCompleted, "Battle is not yet completed");
        require(battle.winner == playerAddress, "Only the suspected winner of the battle can access this function");
        require(battle.leafVerificationPassed, "Leaf verification has to be passed first");
        require(!battle.shipPositionVerificationPassed, "Ship Positions Verification has already been passed");
        
        
        uint8[] memory orderedPositions;
        uint8[] memory calculatedOrderedpositions;
        AxisType[5] memory axis;
        (orderedPositions, axis) = gameLogic.getOrderedpositionAndAxis(leafs);
        uint8[5] memory startingPositions = [orderedPositions[0], orderedPositions[2], orderedPositions[5], orderedPositions[8], orderedPositions[12]];
        ShipType[5] memory shipType = [ShipType.Destroyer, ShipType.Submarine, ShipType.Cruiser, ShipType.Battleship, ShipType.Carrier];
        calculatedOrderedpositions = gameLogic.getPositionsOccupiedByShips(shipType, startingPositions, axis);
        bool isPositionValid = gameLogic.CheckEqualArray(calculatedOrderedpositions, orderedPositions);
        ShipPositionVerificationComplete(_battleId, playerAddress, isPositionValid);
        
        if(isPositionValid)
        {
            battle.shipPositionVerificationPassed = true;
            dataStorageContract.updateBattle(_battleId, battle);
        }
        
        return isPositionValid;
        
    }
    

 }