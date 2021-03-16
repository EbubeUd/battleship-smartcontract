const GameLogic = artifacts.require("GameLogic");
const IDataStorageSchema =artifacts.require("IDataStorageSchema");
const ShipType = IDataStorageSchema.ShipType;
const AxisType = IDataStorageSchema.AxisType;

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

        return GameLogic.deployed()
        .then(instance => {
            gameLogic = instance;
            return gameLogic.getShipTypeFromIndex(17);
        })
        .then(shipType => {
            assert.equal(
                shipType.valueOf(),
                IDataStorageSchema.ShipType.None,
                noShipErrorMessage
            )
        })
        
    });

    
    it("Should verify Destroyer Ship Indexes", () => 
    {

        return GameLogic.deployed()
        .then(instance => {
            return instance.getShipInxesFromShipType(IDataStorageSchema.ShipType.Destroyer);
        })
        .then(result => {
            let expectedResult = [0,1];

            for(let i = 0; i< expectedResult.length; i++)
            {
                assert.equal(
                    result[i].words[0],
                    expectedResult[i],
                    "Invalid Indexes for Destroyer"
                );
            }
        })
    });


    it("Should Verify Submarine Ship Indexes", () => 
    {

        return GameLogic.deployed()
        .then(instance => {
            return instance.getShipInxesFromShipType(IDataStorageSchema.ShipType.Submarine);
        })
        .then(result => {
            let expectedResult = [2,3,4];

            for(let i = 0; i<expectedResult.length; i++)
            {
                assert(
                    result[i].words[0],
                    expectedResult[i],
                    "Invalid Indexes for Submarine"
                );
            }
        })
    });


    it("Should Verify Cruiser Ship Indexes", () => 
    {
        return GameLogic.deployed()
        .then(instance => {
            return instance.getShipInxesFromShipType(IDataStorageSchema.ShipType.Cruiser);
        })
        .then(result => {
            let expectedResult = [5,6,7];

            for(let i = 0; i< expectedResult.length; i++)
            {
                assert.equal(
                    result[i].words[0],
                    expectedResult[i],
                    "Invalid Ship Indexes for Cruiser"
                )
            }
        })
    });


    it("Should Verify Battleship Ship Indexes", () => 
    {
        return GameLogic.deployed()
        .then(instance => {
            return instance.getShipInxesFromShipType(IDataStorageSchema.ShipType.Battleship);
        })
        .then(result => {
            let expectedResult = [8,9,10,11];

            for(let i = 0; i < expectedResult.length; i++)
            {
                assert.equal(
                    result[i].words[0],
                    expectedResult[i],
                    "Invalid Ship indexes for Battleship"
                )
            }
        
        })
    });


    it("Should Verify Carrier Ship Indexes", () =>
    {
        return GameLogic.deployed()
        .then(instance => {
            return instance.getShipInxesFromShipType(IDataStorageSchema.ShipType.Carrier);
        })
        .then(result => {
            let expectedResult = [12,13,14,15,16];

            for(let i = 0; i < expectedResult.length; i++)
            {
                assert.equal(
                    result[i].words[0],
                    expectedResult[i],
                    "Invalid Ship indexes for Carrier"
                )
            }
        
        })
    });


    it("Should Verify Equal Arrays", () =>
    {
        let gameLogic;
        let array1 = [0,1,2,3,4,5,6,7,8];
        let array2 = [0,1,2,3,4,5,6,7,8];
        let array3 = [1,2,3,];
        let array4 = [3,2,1];

        return GameLogic.deployed()
        .then(instance => {
            gameLogic = instance;
            return gameLogic.CheckEqualArray(array1, array2);
        })
        .then(result => {
            assert.equal(
                result.valueOf(),
                true,
                "Arrays are equal"
            );
            return gameLogic.CheckEqualArray(array3, array4);
        })
        .then(result => {
            assert.equal(
                result.valueOf(),
                false,
                "Arrays are not equal"
            )
        })
    });


    it("Should Verify Positions on Y Axis", () => 
    {
        let ships = [ShipType.Destroyer, ShipType.Submarine, ShipType.Cruiser, ShipType.Battleship, ShipType.Carrier];
        let startingPositions = [1,2,3,4,5];
        let shipAxis = [AxisType.Y, AxisType.Y, AxisType.Y, AxisType.Y, AxisType.Y];
        let expectedResult = [1, 11, 2, 12, 22, 3, 13, 23, 4, 14, 24, 34, 5, 15, 25, 35, 45];
        return GameLogic.deployed()
        .then(instance => {
            return instance.getPositionsOccupiedByShips(ships, startingPositions, shipAxis);
        })
        .then(result => {

            assert.equal(
                result.length,
                expectedResult.length,
                "Length of positions must be equal"
            )

            for(let i = 0; i < expectedResult.length; i++)
            {
                assert.equal(
                    result[i].words[0],
                    expectedResult[i],
                    "Incorrect Ship placement on the Y axis"
                )
            }
        })
    });

    it("Should Verify Positions on X Axis", () =>
    {
        let ships = [ShipType.Destroyer, ShipType.Submarine, ShipType.Cruiser, ShipType.Battleship, ShipType.Carrier];
        let startingPositions = [1,11,21,31,41];
        let shipAxis = [AxisType.X, AxisType.X, AxisType.X, AxisType.X, AxisType.X];
        let expectedResult = [1, 2, 11, 12, 13, 21, 22, 23, 31, 32, 33, 34, 41, 42, 43, 44, 45];



        return GameLogic.deployed()
        .then(instance => {
            return instance.getPositionsOccupiedByShips(ships, startingPositions, shipAxis);
        })
        .then(result => {
            for(let i = 0; i < expectedResult.length; i++)
            {
                assert.equal(
                    result[i].words[0],
                    expectedResult[i],
                    "Incorrect Ship placement on the X axis"
                )
            }
        })
    })



});