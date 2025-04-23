// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Sub3dCollection.sol";

contract Sub3dCollectionFactory {
    address public owner;
    uint256 public collectionCount;
    mapping(address => bool) public collections;
    mapping(uint256 => address) public collectionAddresses;

    event CollectionCreated(address indexed collectionAddress, string name, string symbol, string baseURI);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function createCollection(string memory name, string memory symbol, string memory baseURI) external onlyOwner returns (address) {
        Sub3dCollection newCollection = new Sub3dCollection(name, symbol, baseURI);
        newCollection.transferOwnership(msg.sender);
        collections[address(newCollection)] = true;
        collectionCount++;
        collectionAddresses[collectionCount] = address(newCollection);
        emit CollectionCreated(address(newCollection), name, symbol, baseURI);
        return address(newCollection);
    }
}