const Migrations = artifacts.require("Migrations");
const Battleship = artifacts.require("Battleship");
const DataStorage = artifacts.require("DataStorage");
const Gamelogic = artifacts.require("Gamelogic");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Gamelogic).then(function(){
    return deployer.deploy(DataStorage, true, Gamelogic.address).then(function(){
      return deployer.deploy(Battleship, DataStorage.address, Gamelogic.address);
    });
  });

};
