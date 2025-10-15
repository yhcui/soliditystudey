// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract MergeSortedArray {

    using Strings for int;
    using Strings for uint;

    function merge(int[] memory a1, int[] memory a2) public pure returns(int[] memory) {

        require(a1.length>0, "a1 length is zeor");
        require(a2.length>0, "a2 length is zeor");
        uint len = a1.length + a2.length;
        int[] memory r = new int[](len);

        uint k = 0;
        uint i =0;
        uint j = 0;
        for (; i < a1.length || j<a2.length;) {

            console.log(string.concat(i.toString(),"---",j.toString()));
            if (i >= a1.length ) {
                r[k] = a2[j];
                j++;
            }else  if (j >= a2.length ) {
                r[k] = a1[i];
                i++;
                
            } else if (a1[i] < a2[j]) {
                r[k] = a1[i];
                i++;
            } else {
                r[k] = a2[j];
                j++;
            }
            k++;

        }
        return r;
    }
}