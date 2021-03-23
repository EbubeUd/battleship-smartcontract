const Battleship = artifacts.require("Battleship");
const IDataStorageSchema =artifacts.require("IDataStorageSchema");
const ShipType = IDataStorageSchema.ShipType;
const AxisType = IDataStorageSchema.AxisType;
const GameMode = IDataStorageSchema.GameMode;


contract("Battleship", accounts => {

    let battleShip;
    let battleId;
    let encryptedMerkleTree = "encryptedmerkletree";
    let playerOne = accounts[0];
    let playerTwo = accounts[1];

    it("Should Join a Lobby", () => 
    {
  
        let rootHash = "0x9f7f8d1d8d0ff72b5492a6dca4170f592c0735ca31dcb3b99cc6305160f8f66f";
        let gamemode = GameMode.Regular;
        

        return Battleship.deployed()
        .then(instance => {
   

            battleShip = instance;
            let valueInWei =  1000000000000000;
            return instance.joinLobby(gamemode, rootHash, encryptedMerkleTree, {from: playerOne, value : valueInWei});
        })
        .then(result => {

            
            assert.equal(
                result.logs[0].event,
                "PlayerJoinedLobby",
                "Event must indicate that a player has joined the lobby"
            );

            assert.equal(
                result.logs[0].args['0'],
                playerOne,
                "Creator account is not valid"
            );

            assert.equal(
                result.logs[0].args['1'].valueOf(),
                gamemode,
                "Game mode is not valid"
            )
            let valueInWei =  1000000000000000;
            return battleShip.joinLobby(gamemode, rootHash, encryptedMerkleTree, {from: playerTwo, value: valueInWei});
        })
        .then(result => {
            
            battleId = result.logs[0].args._battleId.valueOf();
            let _players = result.logs[0].args._players;
            let _gameMode = result.logs[0].args._gameMode.valueOf();

            //Check that the BattleStarted Event is emitted
            assert.equal(
                result.logs[0].event,
                "BattleStarted",
                "Event must indicate that a battle has started"
            );

            //Check if both players are included in the event log for the battle
            assert.equal(
                _players.includes(playerOne) && _players.includes(playerTwo),
                true,
                "Battle must include both players"
            );

            //Check that the game mode is equal to the game mode entered by the initial player and also equal to the game mode entered by the current player
            assert.equal(
                _gameMode == gamemode,
                true,
                "Game mode must be equal to the starting game mode for the Match/Lobby"
            )
        })
 
    });

    it("Should get Player's encrypted Positions", () => 
    {
        return battleShip.getPlayersEncryptedPositions(battleId)
        .then(result => {
            console.log(result.valueOf());

            //Ensure that the merkle tree is correct
            assert.equal(
                result.valueOf(),
                encryptedMerkleTree,
                "Encrypted Merkletree value is wrong"
            )
        })
    });


    it("Should launch an attack", ()=>
    {
        let _previousPositionLeaf = "00000";
        let _previousPositionProof = "0x00";
        let _attackingPosition = 1;
        return battleShip.attack(battleId, _previousPositionLeaf, _previousPositionProof, _attackingPosition, {from: playerTwo})
        .then(result => {
            console.log(result);
        })
    })

})