const DataStorage = artifacts.require("DataStorage");
const IDataStorageSchema =artifacts.require("IDataStorageSchema");
const ShipType = IDataStorageSchema.ShipType;
const AxisType = IDataStorageSchema.AxisType;
const GameMode = IDataStorageSchema.GameMode;

contract("DataStorage", dataStorage=>{
    it("Should set game mode details", ()=>{
        let dataStorage;
        let gameMode = GameMode.Professional;
        let expectedResult = true; 

        const gameModeDetail = {
            stake: 2,
            gameType: gameMode,
            maxTimeForPlayerToPlay: 10
        };
        return DataStorage.deployed()
        .then(instance =>{
            dataStorage = instance;
            return instance.setGameModeDetails(gameMode, gameModeDetail)            
        })
        .then(result=>{
            assert.equal(result.receipt.status, expectedResult, "Incorrect game mode");
        })
    });

    it("Should return correct game mode", ()=>{
        let dataStorage;
        let gameMode = GameMode.Professional;

        return DataStorage.deployed()
        .then(instance=>{
            dataStorage = instance;
            return instance.getGameModeDetails(gameMode);
        })
        .then(result=>{
            assert.equal(result.gameType, gameMode);
        })
    });

    it("Should set amount of time user last session lasted", ()=>{
        let dataStorage;
        let expectedResult = true;
        let battleId = 1000;
        let playTime = 600000;
        return DataStorage.deployed()
        .then(instance=>{
            dataStorage = instance;
            return dataStorage.setLastPlayTime(battleId, playTime);
        })
        .then(result=>{
            assert.equal(result.receipt.status, expectedResult,expectedResult);
        })
    });

    it("Should get amount of time user last session lasted", ()=>{
        let dataStorage;
        let battleId = 1000;
        let playTime = 600000;
        return DataStorage.deployed()
        .then(instance=>{
            dataStorage = instance;
            return dataStorage.getLastPlayTime(battleId);
        })
        .then(result=>{
            assert.equal(result.words[0],playTime);
        })
    });
});

