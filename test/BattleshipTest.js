const Battleship = artifacts.require("Battleship");
const IDataStorageSchema =artifacts.require("IDataStorageSchema");
const ShipType = IDataStorageSchema.ShipType;
const AxisType = IDataStorageSchema.AxisType;
const GameMode = IDataStorageSchema.GameMode;


contract("Battleship", accounts => {

    let battleShip;

    it("Should Join a Lobby", () => 
    {
        let rootHash = "0x9f7f8d1d8d0ff72b5492a6dca4170f592c0735ca31dcb3b99cc6305160f8f66f";
        let gamemode = GameMode.Regular;
        let encryptedMerkleTree = "encryptedmerkletree";

        return Battleship.deployed()
        .then(instance => {
   

            battleShip = instance;
            return instance.joinLobby(gamemode, rootHash, encryptedMerkleTree, { from: accounts[1] });
        })
        .then(result => {
            console.log(result.logs[0].args);

            assert.equal(
                result.logs[0].args['0'],
                accounts[0],
                "Creator account is not valid"
            );

            assert.equal(
                result.logs[0].args['1'].valueOf(),
                gamemode,
                "Game mode is not valid"
            )
            return true;
        })
 
    })

})