// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract BinarySearch {

    function binSearch(int[] memory a1,int target) public pure returns(int index) {
        require(a1.length > 0, "arr length gt 0 ");
        uint i=0;
        uint j = a1.length -1;

        while (i<=j) {
            uint mid = (i+j)/2;
            if(a1[mid] == target) {
                return int(mid);
            } else if (a1[mid] < target) {
                i = mid+1;
            } else if (a1[mid] > target) {
                j = mid-1;
            }
        }
        return -1;
    }
   
}