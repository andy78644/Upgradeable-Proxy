// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
//import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradableProxy is Proxy, Initializable {

    //address delegate;
    //address owner = msg.sender;

    bytes32 private constant proxyOwnerPosition = keccak256("org.zeppelinos.proxy.owner"); 
    bytes32 private constant implementationPosition = keccak256("org.zeppelinos.proxy.implementation");
    
    

    function initialize(address _owner, address Implementation) public initializer {
        setUpgradeabilityOwner(_owner);
        setImplementation(Implementation);
    }
    

    modifier onlyProxyOwner {
        address Owner = proxyOwner();
        require(
            msg.sender == Owner,
            "only owner can call this function"
        );
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