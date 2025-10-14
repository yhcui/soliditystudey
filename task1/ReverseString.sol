// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract ReverseString {

    using Strings for uint256;

    function reverse1(string memory str) public pure returns (string memory) {
        bytes memory org = bytes(str);

        uint256 len = org.length;
        bytes memory resb = new bytes(len);
        
        require(len> 0, "Input string is empty"); 
        uint j = 0;
        for ( uint i = 0; i <2 ; i++ ) {
        //     // resb[j] = org[i];  // Reverse the string
        //     // j++;
        }

        for (int i = int(len - 1); i >=0; i--){
            resb[j] = org[uint(i)];
            j++;
        }
        return string(resb);
        // return len.toString();
    }

    function reverse2(string memory str2) public pure returns (string memory) {
        bytes memory org = bytes(str2);
        uint256 len = org.length;
        require(len> 0, "Input string is empty");
        bytes memory resb = new bytes(len);

        for (uint i = 0; i < len; i++) {
            resb[i] = org[len -i - 1];
        }
        return string(resb);

    }

    function reverse3(string memory str3) public pure returns (string memory) {
        bytes memory org = bytes(str3);
        uint256 len = org.length;
        require(len> 0, "Input string is empty");

        
        for (uint i = 0; i < len/2; i++) {
            uint j =  len - i -1;
            (org[i],org[j]) = (org[j],org[i]);
        }

        return string(org);
    }

    function reverse4(string memory str3) public pure returns (string memory) {
        bytes memory org = bytes(str3);
        uint256 len = org.length;
        require(len> 0, "Input string is empty");

        
        for (uint i = 0; i < len/2; i++) {
            uint j =  len - i -1;

       
            bytes1 bb = org[j];
            org[j] = org[i];
            org[i] = bb;

        }

        return string(org);
    }
    
}