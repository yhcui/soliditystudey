// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/access/Ownable.sol";
contract BeggingContract is Ownable {

    mapping(address => uint256) private _donate;

    uint256 private immutable startTime;

    uint256 private immutable endTime;

    uint256 private constant _duration = 1;

    event Donation(address indexed, uint256 value);

    constructor() Ownable(msg.sender) {
        startTime = block.timestamp;
        endTime = startTime + _duration *60;
    }

    function donate() public payable {
        
        require(msg.value >0, "donate value must great than 0");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "time is not allowed");
        _donate[msg.sender] +=  msg.value;
        emit Donation(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner returns(bool){
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        return success;
    }
    function getDonation(address aa) public view returns (uint256) {
        return _donate[aa];
    }

    receive() external payable { }
    fallback() external payable { }
}