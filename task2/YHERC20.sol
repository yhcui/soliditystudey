// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract YHERC20 {

    
    mapping(address=> mapping(address=>uint256)) private _approve;

    mapping(address => uint256) private  _balances;

    uint256 private _totalSupply;

    address private _owner;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    constructor() {
        _owner =  msg.sender;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256){
        return _balances[account];
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(_balances[msg.sender]>=value, "insufficient balance");
        require(to != address(0), "0 address is not allowed");
        _balances[msg.sender] = _balances[msg.sender] - value;
        _balances[to] = _balances[to]+value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _approve[owner][spender];
    }

     function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0), "0 address is not allowed");
        _approve[msg.sender][spender]  += value;

        emit Approval(msg.sender, spender, value);
        return true;
     }

     function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(_approve[from][msg.sender] >= value, "insufficient allowance" );
        require(_balances[from] >= value, "insufficient balance");
        _approve[from][msg.sender]  -= value;
        _balances[from]  -= value;
        _balances[to] = value;
        emit Transfer(msg.sender, to, value);
        return true;
     }

     function mint(uint256 value) external returns(bool) {
        require(msg.sender == _owner, "not allow minit");
        _totalSupply += value;
        _balances[msg.sender] += value;
        return true;
     }

    receive() external payable { }

    fallback() external payable { }

}