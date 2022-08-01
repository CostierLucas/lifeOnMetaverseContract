// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface contractUSDC {
    function transferFrom(address, address, uint) external returns (bool);
}

contract ERC721Token is ERC721Enumerable, Ownable, Pausable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;

    struct Category {
        string baseUri;
        uint256 maxSupply;
        uint256 counterSupply;
        uint256 NFTPrice;
        uint256[] tokensIds;
    }

    // Mapping category/info
    mapping(uint256 => Category) public categories;

    // Mapping id/category
    mapping(uint256 => uint256) public NFTcategory;

    //Constructor
    constructor(string memory _baseUriGold, string memory _baseUriPlatinum, string memory _baseUriDiamond, uint _MAX_SUPPLY_Gold, uint _MAX_SUPPLY_Platinum, uint _MAX_SUPPLY_Diamond, uint _priceGold, uint _pricePlatinum, uint _priceDiamond)
    ERC721("test", "TT") {
        categories[0].baseUri = _baseUriGold;
        categories[0].maxSupply = _MAX_SUPPLY_Gold;
        categories[0].counterSupply = 0;
        categories[0].NFTPrice = _priceGold;
        categories[1].baseUri = _baseUriPlatinum;
        categories[1].maxSupply = _MAX_SUPPLY_Platinum;
        categories[1].counterSupply = 0;
        categories[1].NFTPrice = _pricePlatinum;
        categories[2].baseUri = _baseUriDiamond;
        categories[2].maxSupply = _MAX_SUPPLY_Diamond;
        categories[2].counterSupply = 0;
        categories[2].NFTPrice = _priceDiamond;
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
    * @param _id id of the categories
    **/
    function crossMint(uint _id) public payable {
        uint256 newItemId = _tokenIds.current();
        require(msg.sender == 0xdAb1a1854214684acE522439684a145E62505233,
        "This function is for Crossmint only."
        );
        _tokenIds.increment();
        _safeMint(msg.sender, newItemId);
    }

    /**
    * @notice Mint function with USDC
    *
    * @param _quantity Amount of NFTs the user wants to mint
    * @param _id id of the categories
    **/
    function mintUSDC(uint _quantity, uint _id) external payable callerIsUser whenNotPaused{
        uint price = categories[_id].NFTPrice;
        uint256 newItemId = _tokenIds.current();
        require( price != 0, "Price is 0");
        require( _quantity <= categories[_id].maxSupply - categories[_id].counterSupply, "Not enought supply");
        _tokenIds.increment();
        contractUSDC(usdc).transferFrom(msg.sender, address(this), _quantity);
        _safeMint(msg.sender, newItemId);
    }


    /**
    * @notice Get the token URI of an NFT by his ID
    *
    * @param _tokenId The ID of the NFT you want to have the URI of the metadatas
    *
    * @return the token URI of an NFT by his ID
    */
    function tokenURI(uint _tokenId) public view virtual override returns(string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");

        for (uint256 i = 0; i <= 2; i++) {
            if (categories[i].tokensIds.length > 0) {
                for (uint256 j = 0; j < categories[i].tokensIds.length; j++) {
                    if (categories[i].tokensIds[j] == _tokenId) {
                        return string(abi.encodePacked(categories[i].baseUri, _tokenId.toString(), ".json"));
                    }
                }
            }
        }

        return "";
    }

    /**
    * @notice Mint function with MATIC
    *
    * @param _quantity Amount of NFTs the user wants to mint
    * @param _id id of the categories
    **/
    function mintMatic(uint _quantity, uint _id) external payable callerIsUser whenNotPaused{
        uint price = categories[_id].NFTPrice;
        uint256 newItemId = _tokenIds.current();
        require( price != 0, "Price is 0");
        require( _quantity * price <= msg.value, "Not enought MATIC");
        require( _quantity <= categories[_id].maxSupply - categories[_id].counterSupply, "Not enought supply");
        _tokenIds.increment();
        _safeMint(msg.sender, newItemId);
        categories[_id].counterSupply += _quantity;
    }
    

    /**
    * @notice Change the base URI of the NFTs gold
    *
    * @param _baseUriGold the new base URI of the NFTs
    */
    function setBaseUriGold(string memory _baseUriGold) external onlyOwner {
        categories[0].baseUri = _baseUriGold;
    }


    /**
    * @notice Change the base URI of the NFTs Platinum
    *
    * @param _baseUriPlatinum the new base URI of the NFTs
    */
    function setBaseUriPlatinum(string memory _baseUriPlatinum) external onlyOwner {
        categories[1].baseUri = _baseUriPlatinum;
    }


    /**
    * @notice Change the base URI of the NFTs Diamond
    *
    * @param _baseUriDiamond the new base URI of the
    */
    function setBaseUriDiamond(string memory _baseUriDiamond) external onlyOwner {
        categories[2].baseUri = _baseUriDiamond;
    }


    /**
    * @notice Change price for NFTs gold
    *
    * @param _priceGold new price for gold NFTs
    */
    function setPriceGold(uint _priceGold) external onlyOwner {
        categories[0].NFTPrice = _priceGold;
    }

    /**
    * @notice Change price for platinum NFTs
    *
    * @param _pricePlatinum new price for Platinum NFTs
    */
    function setPricePlatinum(uint _pricePlatinum) external onlyOwner {
        categories[1].NFTPrice = _pricePlatinum;
    }


    /**
    * @notice Change price for Diamond NFTs
    *
    * @param _priceDiamond new price for Diamond NFTs
    */
    function setPriceDiamond(uint _priceDiamond) external onlyOwner {
        categories[2].NFTPrice = _priceDiamond;
    }


    /**
    * @notice Change supply for gold NFTs
    *
    * @param _MAX_SUPPLY_Gold new price for gold NFTs
    */
    function setSupplyGold(uint _MAX_SUPPLY_Gold) external onlyOwner {
        categories[0].maxSupply = _MAX_SUPPLY_Gold;
    }

    /**
    * @notice Change supply for platinum NFTs
    *
    * @param _MAX_SUPPLY_Platinum new price for platinum NFTs
    */
    function setSupplyPlatinum(uint _MAX_SUPPLY_Platinum) external onlyOwner {
        categories[1].maxSupply = _MAX_SUPPLY_Platinum;
    }

    /**
    * @notice Change supply for Diamond NFTs
    *
    * @param _MAX_SUPPLY_Diamond new price for Diamond NFTs
    */
    function setSupplyDiamond(uint _MAX_SUPPLY_Diamond) external onlyOwner {
        categories[2].maxSupply = _MAX_SUPPLY_Diamond;
    }
}







