// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "./UpgradableProxy.sol";
import "./SafeUpgradeable.sol";
import "./SafeContract.sol";

contract SafeFactory {
    address owner;
    address safeImplementation;
    event SafeProxy(address ProxyPosition); //to show deploy proxy
    event DeploySafe(address SafePosition); //to show deploy original safe contract
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
        emit SafeProxy(address(myProxy));
        return address(myProxy);
    }

    function deploySafe() external onlyOwner returns (address) {
        Safe safe = new Safe(msg.sender);
        emit DeploySafe(address(safe));
        return address(safe);
    }

    //show Factory owner
    function factoryOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "SafeFactory: caller is not the owner");
        _;
    }
}