const GameLogic = artifacts.require("GameLogic");
const IDataStorageSchema =artifacts.require("IDataStorageSchema");

contract("GameLogic", accounts => {
    let destroyerErrorMessage = "Ship Type must be of type of Destroyer";
    let submarineErrorMessage = "Ship Type must be of type Submarine";
    let cruiserErrorMessage = "Ship Type must be of type Cruiser";
    let battleshipErrorMessage = "Ship Type must be of type Battleship";
    let carrierErrorMessage = "Ship Type must be of type Carrier";
    let noShipErrorMessage = "Ship Type must be of Type None";

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
                destroyerErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(1);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Destroyer,
                destroyerErrorMessage
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
                submarineErrorMessage
            )
            return gameLogic.getShipTypeFromIndex(3);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Submarine,
                submarineErrorMessage
            )
            return gameLogic.getShipTypeFromIndex(4);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Submarine,
                submarineErrorMessage
            )
        })
    });


    it("Should verify Cruiser Ship Index", () => 
    {
        let gameLogic;

        return GameLogic.deployed()
        .then(instance => {
            gameLogic = instance;
            return gameLogic.getShipTypeFromIndex(5);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Cruiser,
                cruiserErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(6);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Cruiser,
                cruiserErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(7)
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Cruiser,
                cruiserErrorMessage
            )
        })
    });


    it("Should verify Battleship Index", () =>
    {
        let gameLogic;

        return GameLogic.deployed()
        .then(instance => {
            gameLogic = instance;
            return gameLogic.getShipTypeFromIndex(8);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Battleship,
                battleshipErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(9);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Battleship,
                battleshipErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(10);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Battleship,
                battleshipErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(11);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Battleship,
                battleshipErrorMessage
            )
        })

    });


    it("Should verify Carrier Index", () => 
    {
        let gameLogic;

        return GameLogic.deployed()
        .then(instance => {
            gameLogic = instance;
            return gameLogic.getShipTypeFromIndex(12);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Carrier,
                carrierErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(13);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Carrier,
                carrierErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(14);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Carrier,
                carrierErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(15);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Carrier,
                carrierErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(16);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.Carrier,
                carrierErrorMessage
            )
        })
   
    });

    
    it("Should verify that Invalid Index returns No ship", () => 
    {
        let gameLogic;

        GameLogic.deployed()
        .then(instance => {
            gameLogic = instance;
            return gameLogic.getShipTypeFromIndex(-1);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.None,
                noShipErrorMessage
            );
            return gameLogic.getShipTypeFromIndex(17);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.None,
                noShipErrorMessage
            )
        })
        
    })




});