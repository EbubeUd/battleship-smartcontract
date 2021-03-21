 // SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;

contract MerkleProof {


  function checkProof(bytes memory proof, bytes32 root, bytes32 hash) public pure returns (bool) {
    bytes32 el;
    bytes32 h = hash;

    for (uint256 i = 32; i <= proof.length; i += 32) {
        assembly {
            el := mload(add(proof, i))
        }

        if (h < el) {
            h = keccak256(abi.encodePacked(h, el));
        } else {
            h = keccak256(abi.encodePacked(el, h));
        }
    }

    return h == root;
  }

  // from StorJ -- https://github.com/nginnever/storj-audit-verifier/blob/master/contracts/MerkleVerifyv3.sol
  function checkProofOrdered(
    bytes memory proof, bytes32 root, string memory hash, uint256 index) public pure returns (bool) {
    // use the index to determine the node ordering
    // index ranges 1 to n

    bytes32 el;
    bytes32 h;
    uint256 remaining;
    bool isHashed = false;

    for (uint256 j = 32; j <= proof.length; j += 32) {
      assembly {
        el := mload(add(proof, j))
      }

      // calculate remaining elements in proof
      remaining = (proof.length - j + 32) / 32;

      // we don't assume that the tree is padded to a power of 2
      // if the index is odd then the proof will start with a hash at a higher
      // layer, so we have to adjust the index to be the index at that layer
      while (remaining > 0 && index % 2 == 1 && index > 2 ** remaining) {
        index = uint(index) / 2 + 1;
      }

      if(!isHashed){
        if (index % 2 == 0) {
          h = keccak256(abi.encodePacked(el, hash));
          index = index / 2;
        } else {
          h = keccak256(abi.encodePacked(hash, el));
          index = uint(index) / 2 + 1;
        }
        isHashed = true;
      }else{
          if (index % 2 == 0) {
          h = keccak256(abi.encodePacked(el, h));
          index = index / 2;
        } else {
          h = keccak256(abi.encodePacked(h, el));
          index = uint(index) / 2 + 1;
        }
      }

    }

    return h == root;
  }
  
  

  
  
  function checkProofsOrdered(bytes[] memory proofs, bytes32 root, string memory leafs) public pure returns (bool)
  {
      bool valid = true;

      //Loop through the Leafs
      string memory leaf = "";

      for(uint8 i = 0; i < 100; i+=5)
      {
        bytes memory proof = proofs[i];
        leaf = getSlice(i+1, i+4, leafs);
        uint8 index = i+1;
        bool result = checkProofOrdered(proof, root, leaf, index);
        if(!result) {
            valid = false;
            break;
        }
      }
      return valid;
  }

  function getSlice(uint256 begin, uint256 end, string memory text) public pure returns (string memory) {
        bytes memory a = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){
            a[i] = bytes(text)[i+begin-1];
        }
        return string(a);
    }

  
}