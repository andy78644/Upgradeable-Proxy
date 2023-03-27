// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract SafeUpgradeable is Initializable {
    address public owner;
    mapping (address => mapping(address => uint256)) public balances;
    mapping (address => uint256) public fees;
    
    function initialize(address _owner) public initializer {
        owner = _owner;
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "only owner can call this function"
        );
        _;
    }
    function deposit(uint256 amount, address token) public {
        require(amount > 0, "Deposit amount must be greater than zero");
        require(IERC20(token).balanceOf(msg.sender) >= amount, "Insufficient balance");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender][token] += amount * 999;
        fees[token] += amount; 
    }

    function withdraw(uint256 amount, address token) public {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(balances[msg.sender][token] >= amount, "Insufficient balance");
        IERC20(token).transfer(msg.sender, amount);
        balances[msg.sender][token] -= amount;
    }

    function takeFee(address token) 
        public 
        onlyOwner
    {
        require(fees[token] > 0, "Insufficient fees");
        IERC20(token).transfer(owner, fees[token]);
    }

    function getOwner()
        public view
        returns (address)
    {
        return owner;
    }
}