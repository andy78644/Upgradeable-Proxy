// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
//import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradableProxy is Proxy {

    //address delegate;
    //address owner = msg.sender;

    bytes32 private constant proxyOwnerPosition = keccak256("org.zeppelinos.proxy.owner"); 
    bytes32 private constant implementationPosition = keccak256("org.zeppelinos.proxy.implementation");
    
    constructor(address _owner, address Implementation) {
        setUpgradeabilityOwner(_owner);
        setImplementation(Implementation);
    }
    
    modifier onlyProxyOwner {
        require(msg.sender == proxyOwner());
        _;
    }

    function upgradeTo(address newImplementation) public onlyProxyOwner {   
        address currentImplementation = _implementation();   
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

    function setImplementation(address newImplementation) internal {   
        bytes32 position = implementationPosition;   
        assembly {
            sstore(position, newImplementation)
        } 
        (bool success, bytes memory result) = newImplementation.delegatecall(abi.encodeWithSignature("initialize(address)", proxyOwner()));
    } 
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