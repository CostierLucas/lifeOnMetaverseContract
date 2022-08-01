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
    function balanceOf(address) external view returns (uint);
}

contract ERC721Token is ERC721Enumerable, Ownable, Pausable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string[] public categories;
    string[] public baseUri;
    uint[] public price;
    uint[] public maxSupply;
    uint[] public counterSupply;
    uint[] public percentages;
    uint[2][] public tokensIds;

    address public usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    
    //Constructor
    constructor(string[] memory _categories, string[] memory _baseUri, uint[] memory _price, uint[] memory _maxSupply, uint[] memory _counterSupply, uint[] memory _percentages)
    ERC721("test", "TT") {
        categories = _categories;
        baseUri = _baseUri;
        price = _price;
        maxSupply = _maxSupply;
        counterSupply = _counterSupply;
        percentages = _percentages;
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
    function crossMint(uint _id, uint _quantity) public payable {
        require( price[_id] != 0, "Price is 0");
        require( _quantity <= maxSupply[_id] - counterSupply[_id], "Not enought supply");
        require(msg.sender == 0xdAb1a1854214684acE522439684a145E62505233,
        "This function is for Crossmint only."
        );
        if( _quantity > 1 ){
            for (uint i = 1; i < _quantity; i++) {
                _safeMint(msg.sender, _tokenIds.current());
                _tokenIds.increment();
            }
        }else{
            _safeMint(msg.sender, _tokenIds.current());
            _tokenIds.increment();
        }
        counterSupply[_id] += _quantity;
    }


    /**
    * @notice Mint function with USDC
    *
    * @param _quantity Amount of NFTs the user wants to mint
    * @param _id id of the categories
    **/
    function mintUSDC(uint _quantity, uint _id) external payable callerIsUser whenNotPaused{
        require( price[_id] != 0, "Price is 0");
        require( _quantity <= maxSupply[_id] - counterSupply[_id], "Not enought supply");
        require(contractUSDC(usdc).balanceOf(msg.sender) >= _quantity * price[_id], "Not enought USDC");
        contractUSDC(usdc).transferFrom(msg.sender, address(this), _quantity);

        if( _quantity > 1 ){
            for (uint i = 1; i < _quantity; i++) {
                _safeMint(msg.sender, _tokenIds.current());
                _tokenIds.increment();
            }
        }else{
            _safeMint(msg.sender, _tokenIds.current());
            _tokenIds.increment();
        }
        counterSupply[_id] += _quantity;
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

        for(uint i = 0; i < tokensIds.length; i++) {
            if(tokensIds[i][1] == _tokenId) {
                return string(abi.encodePacked(baseUri[tokensIds[i][0]], _tokenId.toString(), ".json"));
            }
        }
        return "";
    }


    /**
    * @notice add a new category to the contract
    *
    * @param _categories the category you want to add
    * @param _baseUri the base URI of the category you want to add
    * @param _price the price of the category you want to add
    * @param _maxSupply the max supply of the category you want to add
    * @param _percentages the percentage of the category you want to add
    */
    function addCategory(string memory _categories, string memory _baseUri, uint _price, uint _maxSupply, uint _percentages) external onlyOwner {
        categories.push(_categories);
        baseUri.push(_baseUri);
        price.push(_price);
        maxSupply.push(_maxSupply);
        percentages.push(_percentages);
        counterSupply.push(0);
    }


    /**
    * @notice remove category from the array
    *
    * @param _index index number of the category you want to remove
    */
    function removeCategory(uint256 _index) external onlyOwner {
        require(categories.length > _index, "Index is too high");
        delete categories[_index];
        delete baseUri[_index];
        delete price[_index];
        delete maxSupply[_index];
        delete counterSupply[_index];
        delete percentages[_index];
    }


    /**
    * @notice pause the contract
    */
    function setPaused() external onlyOwner {
        _pause();
    }

    /**
    * @notice unpause the contract
    */
    function setUnPaused() external onlyOwner {
        _unpause();
    }
}







