// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Sub3dCustom is ERC721, ERC721URIStorage, AccessControl {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public tokenIdCounter;
    bool public isSaleActive;
    uint256 public constant MINT_PRICE = 0 ether;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function safeMint(address to, string memory uri) public payable {
        require(isSaleActive, "Token minting is not active");
        require(msg.value >= MINT_PRICE, "Incorrect Amount supplied");
        uint256 tokenId = tokenIdCounter;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        tokenIdCounter += 1;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721,ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function flipSaleActive() public onlyRole(DEFAULT_ADMIN_ROLE) {
        isSaleActive = !isSaleActive;
    }

    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer Failed");
    }
}