// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;

import "./lib/ReentrancyGuard.sol";
import "./interfaces/IDataStorage.sol";
import "./interfaces/IDataStorageSchema.sol";
import "./lib/biconomy/BasicMetaTransaction.sol";
import "./lib/merkletree/MerkleProof.sol";
import "./GameLogic.sol";



 /**
 * @title Battleship
 * @dev Store & retrieve value in a variable
 */

 contract Battleship is ReentrancyGuard, BasicMetaTransaction, IDataStorageSchema, MerkleProof {

    IDataStorage dataStorageContract;
    MerkleProof merkleProof;
    HelperFunctions helperFunctions;
    GameLogic gameLogic;
    address payable owner;

    constructor(address _dataStorageContract) 
    {
        //Set the shipSizes
        dataStorageContract = IDataStorage(_dataStorageContract);
        merkleProof = new MerkleProof();
        gameLogic = new GameLogic();
        owner = payable(address(msgSender()));
    }
    
    event PlayerJoinedLobby(address _playerAddress, GameMode _gameMode);
    event BattleStarted(uint _battleId, GameMode _gameMode, address[2] players);
    event ConfirmShotStatus(uint _battleId, address _confirmingPlayer, address _opponent, uint8 _position, byte _shipDetected);
    event AttackLaunched(uint _battleId, address _launchingPlayer, address opponent, uint8 _position);
    event WinnerDetected(uint _battleId, address _winnerAddress, address _opponentAddress);
    event ConfirmWinner(uint _battleId, address _winnerAddress, address _opponentAddress, uint reward);
    event Transfer(address _to, uint _amount, uint _balance);
    event MerkleTreeLeafVerificationComplete(uint _battleId, address _winnerAddress, bool _verificationResult);
    event ShipPositionVerificationComplete(uint _battleId, address _winnerAddress, bool _verificationResult);
    
    
    
    function joinLobby(GameMode _gameMode, bytes32 _root, string memory _encryptedMerkleTree) public payable returns (uint)
    {
        uint deposit = msg.value;
        address player = msg.sender;
        uint battleId = 0;
        

        //get the Game mode
        GameModeDetail memory gameModeDetail = dataStorageContract.getGameModeDetails(_gameMode);
        
        //Require that the amount of money sent in greater or equal to the required amount for this mode.
        require(deposit >= gameModeDetail.stake, "The amount of money deposited must be equal to the staking amount for this game mode");
        
        //Get the Lobby
        LobbyModel memory lobby = dataStorageContract.getLobby(_gameMode);
        
        //require that the sender is not already in the lobby
        require(lobby.occupant != player, "The occupant can not join in as the player");
        
        //Check if there is currenly a player in the lobby
        if(!lobby.isOccupied) 
        {
            lobby.occupant = player;
            lobby.isOccupied = true;
            lobby.positionRoot = _root;
            lobby.encryptedMerkleTree = _encryptedMerkleTree;
            emit PlayerJoinedLobby(player, _gameMode);

        }else
        {
            //Start a new match
            uint totalStake = gameModeDetail.stake * 2;
            battleId = dataStorageContract.getNewGameId();
            BattleModel memory battle  = BattleModel(totalStake, lobby.occupant, player, block.timestamp, player, false, address(0), _gameMode, gameModeDetail.maxTimeForPlayerToPlay, false, 0, block.timestamp, block.timestamp, false, false);
            
            //Set the encrypted merkle tree for both players
            dataStorageContract.setEncryptedMerkleTree(battleId, battle.host, lobby.encryptedMerkleTree);
            dataStorageContract.setEncryptedMerkleTree(battleId, battle.client, _encryptedMerkleTree);
            
            //Set the merkle tree root for both players.
            dataStorageContract.setMerkleTreeRoot(battleId, battle.host, lobby.positionRoot);
            dataStorageContract.setMerkleTreeRoot(battleId, battle.client, _root);
            
            lobby.occupant = address(0);
            lobby.isOccupied = false;
            lobby.positionRoot = "0x00";
            lobby.encryptedMerkleTree = "";
            dataStorageContract.updateBattle(battleId, battle);
            
     
            
            emit BattleStarted(battleId, _gameMode, [battle.host, battle.client]);

        }
        
        //Update the lobby
        dataStorageContract.updateLobby(_gameMode, lobby);
        return battleId;
    }
    
    
    function getPlayersEncryptedPositions(uint _battleId) public view returns (string memory)
    {
        //Get the ship positions for the battle
        return dataStorageContract.getEncryptedMerkleTree(_battleId, msg.sender);
    }
    
    function getPositionsAttacked(uint _battleId, address _player) public view returns(uint8[] memory)
    {
        return dataStorageContract.getPositionsAttacked(_battleId, _player);
    }
    
    
    function attack(uint _battleId, bytes32 _previousPositionLeaf, bytes memory _previousPositionProof, uint8 _attackingPosition) public returns (bool)
    {
        BattleModel memory battle = dataStorageContract.getBattle(_battleId);
        GameModeDetail memory gameModeDetail = dataStorageContract.getGameModeDetails(battle.gameMode);
        address playerAddress = msg.sender;
        address opponentAddress = battle.host == msg.sender ? battle.client : battle.host;
        uint8 previousPositionIndex = dataStorageContract.getLastFiredPositionIndex(_battleId, opponentAddress);
        bytes32 root = dataStorageContract.getMerkleTreeRoot(_battleId, playerAddress);
        bool proofValidity = merkleProof.checkProofOrdered(_previousPositionProof, root, _previousPositionLeaf, previousPositionIndex);
        address turn = dataStorageContract.getTurn(_battleId);
        uint lastPlayTime = dataStorageContract.getLastPlayTime(_battleId);
        
        require(!battle.isCompleted, "A winner has been detected. Proceed to verify inputs");
        require((block.timestamp - lastPlayTime) < gameModeDetail.maxTimeForPlayerToPlay, "Time to play is expired.");
        require(turn == playerAddress, "Wait till next turn");
        require(proofValidity, "The proof and position combination indactes an invalid move");
        
        //set the position of the last inputed index
        dataStorageContract.setLastFiredPositionIndex(_battleId, playerAddress, _attackingPosition);
        
        //Update the turn
        dataStorageContract.setTurn(_battleId, opponentAddress);
        
        //Update the last play Time
        dataStorageContract.setLastPlayTime(_battleId, block.timestamp);
        
        //set the position index to the list of fired locations.
        dataStorageContract.addPositionAttacked(_battleId, playerAddress, _attackingPosition);
        
        //Get the status of the position hit (0 if there was no ship on it and the id of the ship if there was one on it)
        byte statusOfLastposition = _previousPositionLeaf[0];
        
        //Emit an event containing more details about the last shot that was fired.
        emit ConfirmShotStatus(_battleId, playerAddress, opponentAddress, previousPositionIndex, statusOfLastposition);
        
        //Emit an event indicating that an attack has been launched
        emit AttackLaunched(_battleId, playerAddress, opponentAddress, _attackingPosition);
        
        //Update the array of positions hit.
        
        //Check if we have a winner
        checkForWinner(_battleId, opponentAddress, opponentAddress, statusOfLastposition);
        
        return true;
    }
    
    
    //Checks if there is a winner in the game.
    function checkForWinner(uint _battleId, address _playerAddress, address _opponentAddress, bytes32 _statusOfLastPosition) private returns (bool)
    {
        //Add to the last position hit
        if(_statusOfLastPosition != "0") dataStorageContract.addToCorrectPositionsHit(_battleId, _playerAddress, _statusOfLastPosition);
        
        //Get The total positions hit
        bytes32[] memory correctPositionsHit = dataStorageContract.getCorrectPositionsHit(_battleId, _playerAddress);
        
        if(correctPositionsHit.length == 17)
        {
            //A winner has been found. Call  the game to a halt, and let the verification process begin.
            BattleModel memory battle = dataStorageContract.getBattle(_battleId);
            battle.isCompleted = true;
            battle.winner = _playerAddress;
            dataStorageContract.updateBattle(_battleId, battle);
            emit WinnerDetected(_battleId, _playerAddress, _opponentAddress);
        }
        
        return true;
    }
    
    
    
    function verifyMerkleTreeLeafs(uint _battleId, bytes32[] memory _leafs, bytes[] memory _proofs) public  returns (bool)
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
        bytes32[] memory leafs = dataStorageContract.getRevealedLeafs(_battleId, playerAddress);
        
        //Requirements for process to continue
        require(battle.isCompleted, "Battle is not yet completed");
        require(battle.winner == playerAddress, "Only the suspected winner of the battle can access this function");
        require(battle.leafVerificationPassed, "Leaf verification has to be passed first");
        require(!battle.shipPositionVerificationPassed, "Ship Positions Verification has already been passed");
        
        
        uint8[] memory orderedPositions;
        uint8[] memory calculatedOrderedpositions;
        AxisType[5] memory axis;
        (orderedPositions, axis) = gameLogic.getStartingpositionAndAxis(leafs);
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
    
    
    function collectReward(uint _battleId) public returns (bool)
    {
        BattleModel memory battle = dataStorageContract.getBattle(_battleId);
        address payable playerAddress = payable(msgSender());
        GameModeDetail memory gameModeDetail = dataStorageContract.getGameModeDetails(battle.gameMode);
        address payable transactionOfficer = payable(address(dataStorageContract.getTransactionOfficer()));

        require(battle.isCompleted, "Battle is not yet completed");
        require(battle.winner == playerAddress, "Only the suspected winner of the battle can access this function");
        require(battle.leafVerificationPassed, "Leaf verification has to be passed first");
        require(battle.shipPositionVerificationPassed, "Ship Positions Verification has to be passed");
        
        
         //Get the total reward.
        uint totalReward = gameModeDetail.stake *  2;
        uint transactionCost = 0;
        uint commission = 0;
        uint actualReward = totalReward - transactionCost - commission;
        
        transfer(playerAddress, actualReward);
        transfer(transactionOfficer, transactionCost);
        transfer(owner, commission);
        
        return true;
    }
    
  

    
    
    function transfer(address payable _recipient, uint _amount) private 
     {
         (bool success, ) = _recipient.call{value : _amount}("");
         require(success, "Transfer failed.");
         emit Transfer(_recipient, _amount, address(this).balance);
     }
     
    
    
    
    

    
    
    
  
    
 }