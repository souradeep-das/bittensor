// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract Sub3dCollectionAdvanced is ERC721Enumerable, Ownable {

    string public baseURI;
    bool public isSaleActive;
    uint256 public reserved = 156;
    uint256 public constant MAX_SUPPLY = 3400;
    uint256 public constant MAX_MINT_COUNT = 5;
    uint256 public constant MINT_PRICE = 0.1 ether;
    uint256 public constant MAX_WAGMI_MINT_PER_ADDR = 1;
    uint256 public constant MAX_WAGMI_MINTS = 700;

    address private _signer;

    mapping (address => uint256) public wagmiMintCount;

    constructor(string memory name_, string memory symbol_, string memory initBaseURI_) ERC721(name_, symbol_) Ownable(msg.sender) {
        setBaseURI(initBaseURI_);
        // set signer too
    }

    // donations accepted? else remove payable
    function wagmiMint(uint256 numberOfTokens, bytes memory signature) public payable {
        // add a presale time bool and check here
        require(wagmiMintCount[msg.sender] + numberOfTokens <= MAX_WAGMI_MINT_PER_ADDR, "Address already max WAGMI");
        uint256 supply = totalSupply();
        require(supply + numberOfTokens <= MAX_WAGMI_MINTS, "Mint qty exceeds WAGMI limit");
        // check sig
        require(_verify(_hash(msg.sender, numberOfTokens), signature), "Signature is not valid");

        for(uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, supply + i);
            wagmiMintCount[msg.sender]++;
        }
    }

    function mint(uint256 numberOfTokens) public payable {
        require(isSaleActive, "Token sale is not active");
        uint256 supply = totalSupply();
        require(numberOfTokens <= MAX_MINT_COUNT, "Maximum mint amount per tx exceeded");
        // cannot overflow
        require(supply + numberOfTokens <= MAX_SUPPLY - reserved, "Mint qty exceeds max supply");
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

    function giveAway(address to_, uint256 amount_) public onlyOwner {
        require(amount_ <= reserved, "Maximum reserved mint exceeded");

        uint256 supply = totalSupply();
        for(uint256 i = 0; i < amount_; i++) {
            _safeMint(to_, supply + i);
        }

        reserved -= amount_;
    }

    function withdraw() public onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer Failed");
    }

    function setSigner(address _newSigner) public onlyOwner {
        _signer = _newSigner;
    }

    function _hash(address _account, uint256 _numberOfTokens) internal pure returns(bytes32 hash) {
        hash = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(_account, _numberOfTokens)));
    }

    function _verify(bytes32 digest, bytes memory signature) internal view returns(bool) {
        return _signer == ECDSA.recover(digest, signature);
    }
}
