// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NumtoRoman {

    string[10][4] ro =  [["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"],
        ["", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"],
        ["", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"],
        ["", "M", "MM", "MMM","", "", "", "", "", ""]];

    function numtoRoman(int num) public view returns(string memory ) {
        return string.concat(ro[3][uint256(num/1000)], ro[2][uint256((num/100) %10)], ro[1][uint256((num/10) %10)], ro[0][uint256((num) %10)]);
    }
}