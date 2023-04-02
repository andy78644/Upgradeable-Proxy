// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./UpgradableProxy.sol";
import "./SafeUpgradeable.sol";
import "./SafeContract.sol";

contract SafeFactory {
    address owner;
    address safeImplementation;
    event SafeProxy(address ProxyPosition);
    event DeploySafe(address SafePosition);
    constructor() {
        owner = msg.sender;
    }

    function updateSafeImplementation(address newImplementation) external onlyOwner {
        safeImplementation = newImplementation;
    }

    function getSafeImplementation() public view returns (address){
        return safeImplementation;
    }

    function deploySafeProxy()  external  onlyOwner returns (address) {
        UpgradableProxy myProxy = new UpgradableProxy(msg.sender, safeImplementation);
        //UpgradableProxy myProxy = new UpgradableProxy();
        //myProxy.upgradeTo(safeImplementation);
        emit SafeProxy(address(myProxy));

        return address(myProxy);
    }

    function deploySafe() external onlyOwner returns (address) {
        Safe safe = new Safe(msg.sender);
        emit DeploySafe(address(safe));
        return address(safe);
    }

    function factoryOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "SafeFactory: caller is not the owner");
        _;
    }
}