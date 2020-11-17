pragma solidity ^0.7.4;

import './SwapERC1155.sol';

contract SwapFactory {

    mapping(address => address) public getSwap;

    function createSwap(address _address) public returns (SwapERC1155 swap) {
          require(getSwap[_address] == address(0), "SwapFactory: SWAP EXISTS");
          swap = new SwapERC1155(_address);
          getSwap[_address] = address(swap);
    }
}
