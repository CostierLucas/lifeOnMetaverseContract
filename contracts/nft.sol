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

    struct Category {
        string name;
        string baseUri;
        uint price;
        uint maxSupply;
        uint counterSupply;
        uint percentages;
    }

    Category[] public categories;

    mapping(uint256 => uint256) private TokensByIndexCategory; 

    address public usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    
    //Constructor
    constructor(string[] memory _categories, string[] memory _baseUri, uint[] memory _price, uint[] memory _maxSupply, uint[] memory _percentages)
    ERC721("test", "TT") {
        require(_categories.length == _baseUri.length && _categories.length == _price.length && _categories.length == _maxSupply.length && _categories.length == _percentages.length);
        require(getSum(_percentages) == 100, "The sum of percentages must be 100");
        for(uint i = 0; i < _categories.length; i++) {
            categories.push(Category({
                name: _categories[i],
                baseUri: _baseUri[i],
                price: _price[i],
                maxSupply: _maxSupply[i],
                counterSupply: 0,
                percentages: _percentages[i]
            }));
        }
    }

    /**
    * @notice fallback functions
    */
    receive() external payable {
    }

    /**
    * @notice This contract can't be called by other contracts
    */
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    /**
    * @notice Return sum of array
    * @return sum
    */
    function getSum(uint[] memory _arr) internal pure returns(uint) {
        uint sum = 0;
        for(uint i = 0; i < _arr.length; i++) {
            sum += _arr[i];
        }
        return sum;
    }


    /**
    * @notice Mint function with crossmint
    *
    * @param _id id of the categories
    * @param _quantity quantity of the token
    * @param _proof proof of the token
    **/
    function crossMint(uint _id, uint _quantity, bytes32[] calldata _proof) public payable {
        require( _quantity <= categories[_id].maxSupply - categories[_id].counterSupply, "Not enought supply");
        require(msg.sender == 0xdAb1a1854214684acE522439684a145E62505233,
        "This function is for Crossmint only."
        );
        if( _quantity > 1 ){
            for (uint i = 1; i < _quantity; i++) {
                _safeMint(msg.sender, _tokenIds.current());
                TokensByIndexCategory[_tokenIds.current()] = _id;
                _tokenIds.increment();
            }
        }else{
            _safeMint(msg.sender, _tokenIds.current());
            TokensByIndexCategory[_tokenIds.current()] = _id;
            _tokenIds.increment();
        }
        categories[_id].counterSupply += _quantity;
    }

    /**
    * @notice Mint function with USDC
    *
    * @param _quantity Amount of NFTs the user wants to mint
    * @param _id id of the categories
    **/
    function mintUSDC(uint _quantity, uint _id) external payable callerIsUser whenNotPaused{
        require( _quantity <= categories[_id].maxSupply - categories[_id].counterSupply, "Not enought supply");
        require(contractUSDC(usdc).balanceOf(msg.sender) >= _quantity * categories[_id].price, "Not enought USDC");
        contractUSDC(usdc).transferFrom(msg.sender, address(this), _quantity);

        if( _quantity > 1 ){
            for (uint i = 1; i < _quantity; i++) {
                _safeMint(msg.sender, _tokenIds.current());
                TokensByIndexCategory[_tokenIds.current()] = _id;
                _tokenIds.increment();
            }
        }else{
            _safeMint(msg.sender, _tokenIds.current());
            TokensByIndexCategory[_tokenIds.current()] = _id;
            _tokenIds.increment();
        }
       categories[_id].counterSupply += _quantity;
        
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
        uint indexCategorie = TokensByIndexCategory[_tokenId];

        return string(abi.encodePacked(categories[indexCategorie].baseUri, _tokenId.toString(), ".json"));
    }

    /**
    * @notice distribute %
    *
    * @param _amount amount of tokens to distribute
    */
    function giveStreamRevenue(uint _amount) external{
        contractUSDC(usdc).transferFrom(msg.sender, address(this), _amount);

        for(uint i = 0; i < _tokenIds.current(); i++){
            uint indexCategorie = TokensByIndexCategory[i];
            uint percentage = categories[indexCategorie].percentages;
            uint amount = _amount * percentage / 100;
            contractUSDC(usdc).transferFrom(address(this), ownerOf(i), amount);
        }
    }

    /**
    * @notice claim reward for holders
    *
    * @param _id id of the categories
    *
    */
    function claimAll(uint _id) external payable {
        uint index = balanceOf(msg.sender);
        uint pricePercent = categories[_id].price * categories[_id].percentages / 100;

        for(uint i = 0; i < index; i++) {
            uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
            if(TokensByIndexCategory[tokenId] == _id) {
                contractUSDC(usdc).transferFrom(msg.sender, address(this), pricePercent);
            }
        }
    }

    /**
    * @notice Withdraw for owner
    *
    */
    function withdraw() external payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
		require(success);
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
        categories.push(Category({
            name: _categories,
            baseUri: _baseUri,
            price: _price,
            maxSupply: _maxSupply,
            counterSupply: 0,
            percentages: _percentages
        }));
    }


    /**
    * @notice remove category from the array
    *
    * @param _index index number of the category you want to remove
    */
    function removeCategory(uint256 _index) external onlyOwner {
        require(categories.length > _index, "Index is too high");
        delete categories[_index];
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







