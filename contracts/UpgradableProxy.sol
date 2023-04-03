// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UpgradableProxy is Proxy {

    bytes32 private constant proxyOwnerPosition = keccak256("org.zeppelinos.proxy.owner"); 
    bytes32 private constant implementationPosition = keccak256("org.zeppelinos.proxy.implementation");
    
    constructor(address _owner, address Implementation) {
        setUpgradeabilityOwner(_owner);     //set the owner of the proxy contract
        setImplementation(Implementation);  //set the implementaion which point by this proxy contract
    }
    
    modifier onlyProxyOwner {
        require(msg.sender == proxyOwner());
        _;
    }

    function upgradeTo(address newImplementation) public onlyProxyOwner {   
        setImplementation(newImplementation); 
    } 

    function _implementation() internal view virtual override returns(address impl) {   
        bytes32 position = implementationPosition;   
        assembly {
            impl := sload(position)
        } 
    } 

    function implementation() public view returns(address impl) {   
        bytes32 position = implementationPosition;   
        assembly {
            impl := sload(position)
        }
    }

    //set implemntation contract and call its delegate call
    function setImplementation(address newImplementation) internal {   
        bytes32 position = implementationPosition;   
        assembly {
            sstore(position, newImplementation)
        } 
        (bool success, ) = newImplementation.delegatecall(abi.encodeWithSignature("initialize(address)", proxyOwner()));
        require(success, "initialize funcion fail");
    } 

    //show the owner of this proxy contract
    function proxyOwner() public view returns(address owner) {   
        bytes32 position = proxyOwnerPosition;   
        assembly {
            owner := sload(position)
        } 
    } 

    function setUpgradeabilityOwner(address newProxyOwner) internal {   
        bytes32 position = proxyOwnerPosition;   
        assembly {
            sstore(position, newProxyOwner)
        } 
    }
}