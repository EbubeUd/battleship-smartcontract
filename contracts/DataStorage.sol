
 // SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;
import "./interfaces/IDataStorageSchema.sol";
import "./interfaces/IGameLogic.sol";


contract DataStorage is IDataStorageSchema {

    uint totalTilesRequired = 17; // This means that the total number of occupied spaces in the grid for a game to start should be 17 on both the attacker and the defender;
    uint gameId = 0;
    uint minTimeRequiredForPlayerToRespond = 3 minutes;
    uint maxNumberOfMissiles;
    uint minStakingAmount = uint(0.001 ether);
    uint totalNumberOfPlayers;
    address[] playerAddresses;
    address payable owner;
    address payable transactionOfficer;
    uint rewardComissionRate;
    uint cancelCommissionRate;
    bool isTest;
    
    
    
    address battleShipContractAddress;
    IGameLogic gameLogic;

   
    mapping (ShipType => uint) shipSizes;
    mapping (uint => BattleModel) battles;  //The mapping of battles
    mapping (address => PlayerModel) players;  //The mapping of captains
    
    mapping (uint => mapping(address => mapping(uint => bytes32))) revealedPositions;   //Holds the mapping of the  grid index with its revealed merkletree hash.
    mapping (uint =>  mapping(address => uint8[])) positionsAttacked;    //Maps an array of the locations attacked by each Player
    mapping (uint => mapping(address => string)) encryptedMerkleTree;  //Holds the encrypted merkle tree for each player in a battle
    mapping (uint => mapping(address => bytes32)) merkleTreeRoot;    //Holds the root of the merkle tree. 
    mapping (uint => mapping(address => uint8)) lastFiredPositionIndex; //Holds the index of the last fired position.
    mapping (uint => address) turn;
    mapping (uint => uint) lastPlayTime;
    mapping (uint => mapping(address => ShipPosition[])) correctPositionsHit;   //Holds the array of correct positions hit. used to determine The winner in a match
    mapping (uint => mapping(address => VerificationStatus)) battleVerification;    //Holds each player's verification status in a match.
    mapping (uint => mapping(address => string)) revealedLeafs;  //Holds the revealed leafs of the suspected winner of the each battle.
    
    mapping (GameMode => LobbyModel) lobbyMap;
    mapping (GameMode => GameModeDetail) gameModeMapping;
    
    modifier onlyOwner()
    {
        require(msg.sender == owner, "Only the owner can execute this transaction");
        _;
    }
    
    modifier onlyAuthorized()
    {
        address sender = msg.sender;
        bool isBattleShipContract = sender == battleShipContractAddress;
        require (isBattleShipContract || isTest);
        _;
    }
    
    constructor(bool _isTest, address _gameLogicAddress)   
    {
        gameId = 0;
        owner = payable(address(msg.sender));
        shipSizes[ShipType.Destroyer] = 2;
        shipSizes[ShipType.Submarine] = 3;
        shipSizes[ShipType.Cruiser] = 3;
        shipSizes[ShipType.Battleship] = 4;
        shipSizes[ShipType.Carrier] = 5;
        maxNumberOfMissiles = 5;
        isTest = _isTest;
        gameLogic = IGameLogic(_gameLogicAddress);

        gameModeMapping[GameMode.Regular] = GameModeDetail(minStakingAmount, GameMode.Regular, minTimeRequiredForPlayerToRespond);
        gameModeMapping[GameMode.Intermediate] = GameModeDetail(minStakingAmount, GameMode.Regular, minTimeRequiredForPlayerToRespond);
        gameModeMapping[GameMode.Professional] = GameModeDetail(minStakingAmount, GameMode.Regular, minTimeRequiredForPlayerToRespond);
    }
    

    //Battles
    function getBattle(uint _battleId) public view returns(BattleModel memory)
    {
        return battles[_battleId];
    }
    


    function updateBattle(uint _battleId, BattleModel memory battle) external onlyAuthorized returns (bool)
    {
        battle.updatedAt = block.timestamp;
        if(battle.createdAt < 1) battle.createdAt = block.timestamp;
        battles[_battleId] = battle;
        return true;
    }

    

 
    
    function getNewGameId() external returns (uint)
    {
        gameId++;
        return gameId;
    }


    function setBattleshipContractAddress(address _address) onlyOwner external returns (bool)
    {
        battleShipContractAddress = _address;
        return true;
    }
    
    //Player
    function getPlayer(address _address) public view returns(PlayerModel memory)
    {
        PlayerModel memory player =  players[_address];
        return player;
    }
    
    function getContractOwner() public view returns (address)
    {
        return owner;
    }
    
    function updatePlayer(address _player, PlayerModel memory player) onlyAuthorized external returns (bool)
    {
        player.updatedAt = block.timestamp;
        if(player.createdAt < 1) player.createdAt = block.timestamp;
        players[_player] = player;
        return true;
    }



    

    
   

    
    

    
    
    
    function setGameModeDetails(GameMode _gameMode, GameModeDetail memory _detail) external returns (bool)
    {
        gameModeMapping[_gameMode] = _detail;
        return true;
    }
    
    function getGameModeDetails(GameMode _gameMode) external view returns(GameModeDetail memory)
    {
        return gameModeMapping[_gameMode];
    }
    
    function getLobby(GameMode _gameMode) external view returns (LobbyModel memory)
    {
        return lobbyMap[_gameMode];
    }
    
    function updateLobby(GameMode _gamemode, LobbyModel memory  _lobbyModel) external returns (bool)
    {
        lobbyMap[_gamemode] = _lobbyModel;
        return true;
    }
    
    
    
    
    
    function getEncryptedMerkleTree(uint _battleId, address _player) external view returns(string memory)
    {
        return encryptedMerkleTree[_battleId][_player];
    }
    

    function getRevealedPositionValue(uint _battleId, address _revealingPlayer, uint8 position) external view returns (bytes32)
    {
        return revealedPositions[_battleId][_revealingPlayer][position];
    }
    
    function setEncryptedMerkleTree(uint _battleId, address _player, string memory _encryptedMerkleTree) external returns(bool)
    {
        encryptedMerkleTree[_battleId][_player] = _encryptedMerkleTree;
        return true;
    }
    
    function setRevealedPosition(uint _battleId, address _player, uint position, bytes32 revealedPosition) external returns(bool)
    {
        revealedPositions[_battleId][_player][position] = revealedPosition;
        return true;
    }
    

    
    function getMerkleTreeRoot(uint _battleId, address _playerAddress) external view returns(bytes32)
    {
        return merkleTreeRoot[_battleId][_playerAddress];
    }
    
    function setMerkleTreeRoot(uint _battleId, address _player, bytes32 _merkleTreeRoot) external returns (bool)
    {
        merkleTreeRoot[_battleId][_player] = _merkleTreeRoot;
        return true;
    }
    
    function setLastFiredPositionIndex(uint _battleId, address _player, uint8 _lastFiredPosition) external returns (bool)
    {
        lastFiredPositionIndex[_battleId][_player] = _lastFiredPosition;
        return true;
    }
    
    function getLastFiredPositionIndex(uint _battleId, address _player) external view returns(uint8)
    {
        return lastFiredPositionIndex[_battleId][_player];
    }
    
    function getTurn(uint _battleId) external view returns(address)
    {
        return turn[_battleId];
    }
    
    function setTurn (uint _battleId, address _turn) external returns (bool)
    {
        turn[_battleId]  = _turn;
        return true;
    }
    
    function getLastPlayTime (uint _battleId) external view returns (uint)
    {
        return lastPlayTime[_battleId];
    }
    
    function setLastPlayTime(uint _battleId, uint _playTime) external returns (bool)
    {
        lastPlayTime[_battleId] = _playTime;
        return true;
    }
    
    function addPositionAttacked(uint _battleId, address _player, uint8 position) external returns(bool)
    {
        positionsAttacked[_battleId][_player].push(position);
        return true;
    }
    
    function getPositionsAttacked(uint _battleId, address _player) external view returns(uint8[] memory)
    {
        return positionsAttacked[_battleId][_player];
    }
    
    function getCorrectPositionsHit(uint _battleId, address _player) external view returns(ShipPosition[] memory)
    {
        return correctPositionsHit[_battleId][_player];
    }
    
    function addToCorrectPositionsHit(uint _battleId, address _player, ShipPosition memory _shipPosition) external returns (bool)
    {
        correctPositionsHit[_battleId][_player].push(_shipPosition);
        return true;
    }
    
    function getVerificationStatus(uint _battleId, address _player) external view returns(VerificationStatus)
    {
        return battleVerification[_battleId][_player];
    }
    
    function setVerificationStatus(uint _battleId, address _player, VerificationStatus _status) external returns (bool)
    {
        battleVerification[_battleId][_player] = _status;
        return true;
    }
    
    function getTransactionOfficer() external view returns(address)
    {
        return transactionOfficer;
    }
    
    function setTransationOfficer(address payable _transactionOfficer) external returns(bool)
    {
        transactionOfficer = _transactionOfficer;
        return true;
    }
    
    
    function getRevealedLeafs(uint _battleId, address _playerAddress) external view returns(string memory)
    {
        return revealedLeafs[_battleId][_playerAddress];
    }
    
    
    function setRevealedLeafs(uint _battleId, address _playerAddress, string memory _revealedLeafs) external returns(bool)
    {
        revealedLeafs[_battleId][_playerAddress] = _revealedLeafs;
        return true;
    }

 
    
}
