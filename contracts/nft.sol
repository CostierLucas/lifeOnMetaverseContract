// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract ERC721Token is ERC721Enumerable, Ownable, Pausable {
    using Strings for uint256;

    string public baseUriGold;
    string public baseUriPlatinum;
    string public baseUriDiamond;

    uint public MAX_SUPPLY_Gold;
    uint public MAX_SUPPLY_Platinum;
    uint public MAX_SUPPLY_Diamond;

    uint public priceGold;
    uint public pricePlatinum;
    uint public priceDiamond;

    //Constructor
    constructor(string memory _baseUriGold, string memory _baseUriPlatinum, string memory _baseUriDiamond, uint _MAX_SUPPLY_Gold, uint _MAX_SUPPLY_Platinum, uint _MAX_SUPPLY_Diamond, uint _priceGold, uint _pricePlatinum, uint _priceDiamond)
    ERC721("test", "TT") {
        baseUriGold = _baseUriGold;
        baseUriPlatinum = _baseUriPlatinum;
        baseUriDiamond = _baseUriDiamond;
        MAX_SUPPLY_Gold = _MAX_SUPPLY_Gold;
        MAX_SUPPLY_Platinum = _MAX_SUPPLY_Platinum;
        MAX_SUPPLY_Diamond = _MAX_SUPPLY_Diamond;
        priceGold = _priceGold;
        pricePlatinum = _pricePlatinum;
        priceDiamond = _priceDiamond;
    }

    /**
    * @notice This contract can't be called by other contracts
    */
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    /**
    * @notice Mint function with crossmint
    *
    * @param _quantity Amount of NFTs the user wants to mint
    **/
    function crossmint(uint _quantity) public payable {
        require(msg.sender == 0xdAb1a1854214684acE522439684a145E62505233,
        "This function is for Crossmint only."
        );
        _safeMint(msg.sender, _quantity);
    }


    /**
    * @notice Mint function with USDC
    *
    * @param _quantity Amount of NFTs the user wants to mint
    **/
    function mintUSDC(uint _quantity) external payable callerIsUser whenNotPaused{
        _safeMint(msg.sender, _quantity);
    }

    /**
    * @notice Mint function with MATIC
    *
    * @param _quantity Amount of NFTs the user wants to mint
    **/
    function mintMatic(uint _quantity) external payable callerIsUser whenNotPaused{
        _safeMint(msg.sender, _quantity);
    }

    /**
    * @notice Change the base URI of the NFTs gold
    *
    * @param _baseUriGold the new base URI of the NFTs
    */
    function setBaseUriGold(string memory _baseUriGold) external onlyOwner {
        baseUriGold = _baseUriGold;
    }

    /**
    * @notice Change the base URI of the NFTs Platinum
    *
    * @param _baseUriPlatinum the new base URI of the NFTs
    */
    function setBaseUriPlatinum(string memory _baseUriPlatinum) external onlyOwner {
        baseUriPlatinum = _baseUriPlatinum;
    }

    /**
    * @notice Change the base URI of the NFTs Diamond
    *
    * @param _baseUriDiamond the new base URI of the
    */
    function setBaseUriDiamond(string memory _baseUriDiamond) external onlyOwner {
        baseUriDiamond = _baseUriDiamond;
    }

    /**
    * @notice Change price for NFTs gold
    *
    * @param _priceGold new price for gold NFTs
    */
    function setPriceGold(uint _priceGold) external onlyOwner {
        priceGold = _priceGold;
    }


    /**
    * @notice Change price for platinum NFTs
    *
    * @param _pricePlatinum new price for Platinum NFTs
    */
    function setPricePlatinum(uint _pricePlatinum) external onlyOwner {
        pricePlatinum = _pricePlatinum;
    }


    /**
    * @notice Change price for Diamond NFTs
    *
    * @param _priceDiamond new price for Diamond NFTs
    */
    function setPriceDiamond(uint _priceDiamond) external onlyOwner {
        priceDiamond = _priceDiamond;
    }


    /**
    * @notice Change supply for gold NFTs
    *
    * @param _MAX_SUPPLY_Gold new price for gold NFTs
    */
    function setSupplyGold(uint _MAX_SUPPLY_Gold) external onlyOwner {
        MAX_SUPPLY_Gold = _MAX_SUPPLY_Gold;
    }

    /**
    * @notice Change supply for platinum NFTs
    *
    * @param _MAX_SUPPLY_Platinum new price for platinum NFTs
    */
    function setSupplyPlatinum(uint _MAX_SUPPLY_Platinum) external onlyOwner {
        MAX_SUPPLY_Platinum = _MAX_SUPPLY_Platinum;
    }

    /**
    * @notice Change supply for Diamond NFTs
    *
    * @param _MAX_SUPPLY_Diamond new price for Diamond NFTs
    */
    function setSupplyDiamond(uint _MAX_SUPPLY_Diamond) external onlyOwner {
        MAX_SUPPLY_Diamond = _MAX_SUPPLY_Diamond;
    }
}







