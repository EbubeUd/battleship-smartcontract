const Migrations = artifacts.require("Migrations");
const Battleship = artifacts.require("Battleship");
const DataStorage = artifacts.require("DataStorage");
const GameLogic = artifacts.require("GameLogic");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(GameLogic).then(function(){
    return deployer.deploy(DataStorage, true, GameLogic.address).then(function(){
      return deployer.deploy(Battleship, DataStorage.address, GameLogic.address);
    });
  });

};
