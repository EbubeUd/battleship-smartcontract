const GameLogic = artifacts.require("GameLogic");
const IDataStorageSchema =artifacts.require("IDataStorageSchema");

contract("GameLogic", accounts => {
    it("Should Verify Destroyer Ship Index", () =>
    {
        let gameLogic;


        return  GameLogic.deployed()
        .then(instance => 
            {
                gameLogic = instance;
                return gameLogic.getShipTypeFromIndex(0);
            })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Destroyer,
                "Ship Type must be of type of Destroyer"
            );
            return gameLogic.getShipTypeFromIndex(1);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Destroyer,
                "Ship Type must be of type of Destroyer"
            );
        })
    });

    it("Should Verify Submarine Ship Index", () => 
    {
        let gameLogic;

        return GameLogic.deployed()
        .then(instance => {
            gameLogic = instance;
            return gameLogic.getShipTypeFromIndex(2);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Submarine,
                "Ship Type must be of type Submarine"
            )
            return gameLogic.getShipTypeFromIndex(3);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Submarine,
                "Ship Type must be of Type Submarine"
            )
            return gameLogic.getShipTypeFromIndex(4);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Submarine,
                "Ship Type must be of Type Submarine"
            )
        })
    })
});