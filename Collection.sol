// SPDX-License-Identifier: MIT LICENSE

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.2;

contract Collection is ERC721Enumerable, Ownable {
    using Strings for uint256;
    
    string public baseURI;
    string public baseExtension = ".json";
    uint256 public maxSupply = 100000;
    uint256 public maxMintAmount = 5;
    bool public paused = false;

    // Constructor accepting an initialOwner address
    constructor(address initialOwner) ERC721("Net2Dev NFT Collection", "N2D") Ownable(initialOwner) {}

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
    
    function mint(address _to, uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused, "Contract is paused");
        require(_mintAmount > 0, "Mint amount must be greater than 0");
        require(_mintAmount <= maxMintAmount, "Exceeds max mint amount");
        require(supply + _mintAmount <= maxSupply, "Exceeds max supply");
        
        for (uint256 i = 0; i < _mintAmount; i++) {
            _safeMint(_to, supply + i + 1);
        }
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i = 0; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        // Check if the token exists by trying to get its owner
        address owner = _getTokenOwner(tokenId);
        require(owner != address(0), "ERC721Metadata: URI query for nonexistent token");
        
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    // Helper function to check token existence by ownerOf method
    function _getTokenOwner(uint256 tokenId) internal view returns (address) {
        address owner;
        try this.ownerOf(tokenId) returns (address _owner) {
            owner = _owner;
        } catch {
            owner = address(0);
        }
        return owner;
    }

    // Only owner functions
    function setMaxMintAmount(uint256 _newMaxMintAmount) public onlyOwner {
        maxMintAmount = _newMaxMintAmount;
    }
    
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    
    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }
    
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
    
    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance), "Withdraw failed");
    }
}
