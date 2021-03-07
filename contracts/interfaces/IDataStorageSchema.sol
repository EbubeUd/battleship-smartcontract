 // SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;
interface IDataStorageSchema 
{
    enum PlayerType {Host, Client}
    enum ShipType {Destroyer, Submarine, Cruiser, Battleship, Carrier, None}
    enum AxisType {X, Y}
    enum GameMode {Regular, Intermediate, Professional}
    enum VerificationStatus { Unverified, Ok, Cheated}

       
       
    struct ShipPositionsModel
    {
        uint8[] hostPositionsAttacked;   //Holds the ordered positions of the Host attacked
        uint8[] clientPositionsAttacked; //Holds the Ordered Positions of the client attacked
        bytes32 hostEncryptedMerkleTree;    //Holds the encryped merkle tree positions of the host.
        bytes32 clientEncryptedMerkleTree;  //Holds the encryped merkle tree positions Of the client
        
    }
    
    
    
    
    
    struct BattleModel
    {
        uint stake; //determines how much ethers was staked for this battle
        address host;   //holds the address of the host captain
        address client; //holds the address of the client captain
        uint startTime; // battle start time
        address turn;   //address indicating whose turn it is to play next
        bool isCompleted;   //indicates whether or not the battle has been completed
        address winner; // holds the address of the winning player;
        GameMode gameMode;  //The game mode
        uint maxTimeForPlayerDelay; //If a captain does not play after this time elapses, then the contract will do a random play for the captain and then permit the next player to play. This will be done when the next player decides to play.
        bool isRewardClaimed; //Determines if the reward has been claimed by the winner;
        uint claimTime; //Holds the time that the reward was claimed
        uint createdAt; //Time Created
        uint updatedAt; //Time last Updated
        bool leafVerificationPassed;    //Determines if the winner Of the battle has passed the Leaf Verification Test
        bool shipPositionVerificationPassed;    //Determines if the winner has passed the ship position verification Test
        
    }
    
    
    
    struct  PlayerModel
    {
        string name;   // short name (up to 32 bytes)
        uint matchesPlayed; //total number of matches played 
        uint wins; // total number of wins
        uint losses; // total number of losses
        bool isVerified; // indicates whether or not the account of the captain has been set up
        uint numberOfGamesHosted;   //Total number Of games hosted;
        uint numberOfGamesJoined;   //Total number of Games Joined;
        uint totalStaking;  //The total amount of money that has been staked
        uint totalEarning;  //The total amount of money that has been won
        uint createdAt; //Date Last created;
        uint updatedAt; //Date last updated
    }
    
    struct GameModeDetail
    {
        uint stake;
        GameMode gameType;
        uint maxTimeForPlayerToPlay;
    }
    
    struct LobbyModel
    {
        bool isOccupied;    //Indicates wheather or not there is an occupant in the lobby.
        address occupant;   //Holds the address of the occupant
        bytes32 positionRoot;   //Holds the merkletree root of the player's positions
        string encryptedMerkleTree; //Holds the full merkle tree, encrypted with the user's private key.
    }
    
    struct BattleVerificationModel
    {
        uint battleId;
        bytes32 previousPositionLeaf;
        bytes _previousPositionProof;
        uint8 _attackingPosition;
        bytes[] proofs;
        bytes32[] leafs;
        uint8[] indexes;
    }
    
    struct TransferModel
    {
        address payable recipient;
        uint amount;
    }
    
    struct AttackModel
    {
        address player;
        uint tiles;
    }
    




}