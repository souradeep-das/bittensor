// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract Sub3dCollection is ERC721Enumerable, Ownable {

    string public baseURI;
    bool public isSaleActive;
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant MAX_MINT_COUNT = 20;
    uint256 public constant MINT_PRICE = 0 ether;

    constructor(string memory name_, string memory symbol_, string memory initBaseURI_) ERC721(name_, symbol_) Ownable(msg.sender) {
        setBaseURI(initBaseURI_);
    }

    function mint(uint256 numberOfTokens) public payable {
        require(isSaleActive, "Token sale is not active");
        uint256 supply = totalSupply();
        require(numberOfTokens <= MAX_MINT_COUNT, "Maximum mint amount per tx exceeded");
        // cannot overflow
        require(supply + numberOfTokens <= MAX_SUPPLY, "Mint qty exceeds max supply");
        require(msg.value >= numberOfTokens * MINT_PRICE, "Incorrect Amount supplied");

        for(uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function _baseURI() internal view override returns(string memory) {
        return baseURI;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        baseURI = baseURI_;
    }

    function flipSaleActive() public onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function withdraw() public onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer Failed");
    }
}
