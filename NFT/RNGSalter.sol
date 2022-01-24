// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract RNG {
    uint256 private _salt = 17;
    
    function fetchRandom(uint256 seedOne, uint256 seedTwo) external returns (uint256) {
        uint256 rng = uint256(keccak256(abi.encode(seedOne, seedTwo, _salt, blockhash(block.number))));
        _salt++;
        return rng;
    }
}