require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require('solidity-coverage');
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  gasReporter: {
    enabled: true
  }
};
