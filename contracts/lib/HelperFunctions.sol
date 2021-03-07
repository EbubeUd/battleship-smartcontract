// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;




contract HelperFunctions 
{
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
    }
    
    function getBytes32(bytes32 value) public pure returns(bytes32)
    {
        return value;
    }
    
    function getBytes32FromBytes(bytes memory value, uint index) public pure returns(bytes32)
    {
        bytes32 el;
        uint position = 32 * (index + 1);
        //Require That the length of the bytes covers the position to be read from
        require(value.length >= position, "The value requested is not within the range of the bytes");
       assembly {
        el := mload(add(value, position))
        }
        
        return el;
    }
    
    //Gets a slice from a string
    function getSlice(uint256 begin, uint256 end, string memory text) public pure returns (string memory) {
        bytes memory a = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){
            a[i] = bytes(text)[i+begin-1];
        }
        return string(a);
    }
    

  function getSliceBytes32(uint256 begin, uint256 end, bytes32  text) public pure returns (bytes memory ) {
        bytes memory a = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){
            a[i] = text[i+begin-1];
        }
        return a;
    }
    
    function getFirstCharacterBytes32(bytes32 word) public pure returns (byte)
    {
        return word[0];
    }
    

}