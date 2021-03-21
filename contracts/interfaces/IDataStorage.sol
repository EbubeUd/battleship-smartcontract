
 // SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;
import "./IDataStorageSchema.sol";

interface IDataStorage is IDataStorageSchema
{
    
    
    //Battles
    function getBattle(uint _id) external view returns (BattleModel memory);
    function updateBattle(uint _battleId, BattleModel memory _battle) external returns (bool);
    function getNewGameId() external returns (uint);



    
    //Rules
    function getContractOwner() external view returns (address);
    function setBattleshipContractAddress(address _address) external returns(bool);
    function setGameLogicAddress(address _gameLogicAddress) external returns (bool);
    function setGameModeDetails(GameMode _gameMode, GameModeDetail memory _detail) external returns (bool);
    function getLobby(GameMode _gameMode)  external view returns (LobbyModel memory);
    function getGameModeDetails(GameMode _gameMode) external view returns (GameModeDetail memory);
    function updateLobby(GameMode _gameMode, LobbyModel memory lobby) external returns (bool);
    
    //Player
    function getPlayer(address _address) external view returns(PlayerModel memory);
    function updatePlayer(address _address, PlayerModel memory player) external returns (bool);
    
    
    function getEncryptedMerkleTree(uint _battleId, address _player) external view returns(string memory);
    function setEncryptedMerkleTree(uint _battleId, address _player, string memory _encryptedMerkleTree) external returns(bool);

    function getRevealedPositionValue(uint _battleId, address _revealingPlayer, uint8 position) external view returns (bytes32);
    function setRevealedPosition(uint _battleId, address _player, uint position, bytes32 revealedPosition) external returns(bool);
    
    function getMerkleTreeRoot(uint _battleId, address _playerAddress) external view returns(bytes32);
    function setMerkleTreeRoot(uint _battleId, address _playerAddress, bytes32 merkleTreeRoot) external returns (bool);
    
    function setLastFiredPositionIndex(uint _battleId, address _player, uint8 _lastFiredPosition) external returns (bool);
    function getLastFiredPositionIndex(uint _battleId, address _player) external view returns(uint8);
    
    function getTurn(uint _battleId) external view returns(address);
    function setTurn (uint _battleId, address _turn) external returns (bool);
    
    function getLastPlayTime (uint _battleId) external view returns (uint);
    function setLastPlayTime(uint _battleId, uint _playTime) external returns (bool);
    
    function addPositionAttacked(uint _battleId, address _player, uint8 position) external returns(bool);
    function getPositionsAttacked(uint _battleId, address _player) external view returns(uint8[] memory);
    
    function getCorrectPositionsHit(uint _battleId, address _player) external view returns(ShipPosition[] memory);
    function addToCorrectPositionsHit(uint _battleId, address _player, ShipPosition memory _shipPosition) external returns (bool);
    
    function getVerificationStatus(uint _battleId, address _player) external view returns(VerificationStatus);
    function setVerificationStatus(uint _battleId, address _player, VerificationStatus _status) external returns (bool);
    
    function getTransactionOfficer() external view returns(address);
    function setTransationOfficer(address payable _transactionOfficer) external returns(bool);
    
    function getRevealedLeafs(uint _battleId, address _playerAddress) external view returns(string memory);
    function setRevealedLeafs(uint _battleId, address _playerAddress, string memory _revealedLeafs) external returns(bool);
}