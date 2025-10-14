// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract RomanToNum {
    mapping(string => uint256) rm;

    using Strings for int256;

    using Strings for uint256;

    constructor() {
        rm["I"] = 1;
        rm["V"] = 5;
        rm["X"] = 10;
        rm["L"] = 50;
        rm["C"] = 100;
        rm["D"] = 500;
        rm["M"] = 1000;
    }

    function rton(string memory r) public view returns(uint256) {
        bytes memory bb = bytes(r);
        require(bb.length > 0 ,"input null");
        int256 total;
        for (uint i = 0; i <bb.length;i++) {

            bytes memory tb = new bytes(1);
            tb[0] = bb[i];
            string memory key = string(tb);

            if ( i == bb.length - 1) {
                total += int256(rm[key]);
            } else {
                bytes memory tbn = new bytes(1);
                tbn[0] = bb[i+1];
                string memory nkey = string(tbn);

                console.log("START CAL -----------");
                console.log(key);
                console.log(nkey);
                console.log(uint256(rm[key]).toString());
                console.log(uint256(rm[nkey]).toString());
                // console.log(uint256(rm[nkey] - rm[key]).toString());
                if (rm[key] < rm[nkey]) {
                    
                    total += int256(rm[nkey] - rm[key]);
                    i++;
                } else {
                    total += int256(rm[key]);
                }

                
            }

            
            
        }
        return uint256(total);
    }
}