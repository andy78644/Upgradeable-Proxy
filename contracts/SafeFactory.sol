// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./UpgradableProxy.sol";
import "./SafeUpgradeable.sol";

contract SafeFactory {
    address owner;
    address safeImplementation;
    //address originImplementation;
    //SafeUpgradeable public SafeContract;
    event SafeProxy(address);
    constructor() {
        owner = msg.sender;
        safeImplementation = deploySafe();
        //safeImplementation = originImplementation;
        //setSafeImplementation(originImplementation);

    }

    function updateSafeImplementation(address newImplementation) external onlyOwner {
        safeImplementation = newImplementation;
    }

    function getSafeImplementation() public view returns (address){
        return safeImplementation;
    }

    function deploySafeProxy()  external  onlyOwner returns (address) {
        UpgradableProxy myProxy = new UpgradableProxy();
        myProxy.initialize(msg.sender, safeImplementation);
        //return address(myProxy);
        emit SafeProxy(address(myProxy));
        return address(myProxy);
    }

    function deploySafe() public onlyOwner returns (address) {
        SafeUpgradeable safe = new SafeUpgradeable();
        safe.initialize(msg.sender);
        return address(safe);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "SafeFactory: caller is not the owner");
        _;
    }
}