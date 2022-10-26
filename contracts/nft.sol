// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

// Import this file to use console.log
/* import "hardhat/console.sol"; */ 
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

library StructLib {
    struct Slot{
        uint160 sqrtPriceX96;
        int24 tick;
        uint16 observationIndex;
        uint16 observationCardinality;
        uint16 observationCardinalityNext;
        uint8 feeProtocol;
        bool unlocked;
    }
}

interface contractERC20 {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
    function balanceOf(address) external view returns (uint);
}

interface IUniswapPrice {
    function slot0() view external returns (StructLib.Slot memory);
}


contract ERC721Token is ERC721Enumerable, Pausable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; 

    event OpenseaReceived(address, uint);
    event RoyaltiesReceived(address, uint);

    struct Category {
        string name;
        string baseUri;
        uint price;
        uint maxSupply;
        uint counterSupply;
        uint percentages;
    }

    Category[] public categories;

    mapping(uint => uint) private CategoryById; 
    mapping (uint => uint ) public RoyaltiesClaimablePerCategory;
    mapping (uint => uint ) public RoyaltiesClaimedPerId;

    address public usdc;
    address public artist;
    address public poolContract = 0xA374094527e1673A86dE625aa59517c5dE346d32;
    address investor;
    uint256 percentageInvestor;
    uint256 percentageArtist;
    uint256 percentageArtistOpensea;
    uint256 percentageInvestorOpensea;
    uint256 startDate;
    
    //Constructor
    constructor(string[] memory _categories, string[] memory _baseUri, uint[] memory _price, uint[] memory _maxSupply, uint[] memory _percentages, address _usdc,  address  _artist, address _investor, uint _percentageInvestor, uint _percentageArtist, uint _percentageArtistOpensea, uint _percentageInvestorOpensea , uint _startDate)
    ERC721("test", "TT") {
        require(_categories.length == _baseUri.length && _categories.length == _price.length && _categories.length == _maxSupply.length && _categories.length == _percentages.length, "All arrays must have the same length");
        require(_percentageInvestor + _percentageArtist == 100, "Percentage must be 100");
        require(_percentageInvestorOpensea + _percentageArtistOpensea == 100, "Percentage must be 100");
        require(_investor != address(0), "Investor address must be different from 0");
        require(_artist != address(0), "Artist address must be different from 0");
        require(_usdc != address(0), "USDC address must be different from 0");
        require(getSum(_percentages) == 100, "The sum of percentages must be 100");
        require(_startDate > block.timestamp, "Start date must be in the future");
        structCategories(_categories, _baseUri, _price, _maxSupply, _percentages);
        usdc = _usdc;
        investor = _investor;
        artist = _artist;
        percentageInvestor = _percentageInvestor;
        percentageArtist = _percentageArtist;
        percentageArtistOpensea = _percentageArtistOpensea;
        percentageInvestorOpensea = _percentageInvestorOpensea;
        startDate = _startDate;
        _tokenIds.increment();
    }

    /**
    * @notice onlyInvestor modifier
    */
    modifier onlyInvestor {
        require(msg.sender == investor, 'Ownable: caller is not the owner');
        _;
    }

      /**
    * @notice This contract can't be called by other contracts
    */
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    /**
    * @notice fallback functions
    */
    receive() external payable {
        (bool success1, ) = payable(investor).call{value: ((msg.value * percentageInvestorOpensea) / 100)}("");
		require(success1);
        (bool success2, ) = payable(artist).call{value: (msg.value * percentageArtistOpensea) / 100}("");
		require(success2);
        emit OpenseaReceived(msg.sender, msg.value);
    }

    /**
    * @notice royalties functions
    *
     * @param amount amount of royalties sent by the artist
    */
    function FundRoyalties(uint amount) public onlyInvestor{
        require(amount > 0, "amount can't be 0");
        bool success = contractERC20(usdc).transferFrom(msg.sender, address(this), amount);
        require(success, "Could not transfer token. Missing approval?");
        for(uint i=0; i < categories.length; i++){
            RoyaltiesClaimablePerCategory[i] += ((amount * categories[i].percentages / categories[i].maxSupply ) / 100);
        }
        emit RoyaltiesReceived(msg.sender, amount);
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
    * @notice Add data to categories
    */
    function structCategories(string[] memory _categories, string[] memory _baseUri, uint[] memory _price, uint[] memory _maxSupply, uint[] memory _percentages) internal {
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
    * @notice Mint function with crossmint
    *
    * @param categoryId id of the category
    * @param _quantity quantity of the token
    **/
    function crossMint(address _to, uint categoryId, uint _quantity) public payable {
        require(categoryId < categories.length, "Invalid category");
        require(startDate < block.timestamp, "The sale has not started yet");
        require( _quantity <= categories[categoryId].maxSupply - categories[categoryId].counterSupply, "Not enought supply");
            for (uint i = 0; i < _quantity; i++) {
                _safeMint(_to, _tokenIds.current());
                CategoryById[_tokenIds.current()] = categoryId;
                _tokenIds.increment();
            }
        categories[categoryId].counterSupply += _quantity;
    }

    /**
    * @notice Mint function with USDC
    *
    * @param _quantity Amount of NFTs the user wants to mint
    * @param categoryId id of the category
    **/
    function mintUSDC(uint _quantity, uint categoryId, address _to) external payable whenNotPaused {
        require(categoryId < categories.length, "Invalid category");
        require(startDate < block.timestamp, "The sale has not started yet");
        require( _quantity <= categories[categoryId].maxSupply - categories[categoryId].counterSupply, "Not enought supply");
            for (uint i = 0; i < _quantity; i++) {
                _safeMint(_to, _tokenIds.current());
                CategoryById[_tokenIds.current()] = categoryId;
                _tokenIds.increment();
            }
       categories[categoryId].counterSupply += _quantity;
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
        uint indexCategorie = CategoryById[_tokenId];
        return string(abi.encodePacked(categories[indexCategorie].baseUri));
    }

    /**
    * @notice claim reward for holders
    *
    * @param _tokenId id of the NFT you want to claim rewards from
    *
    */
    function claimRoyalties(uint _tokenId) external {
        require(_tokenId < totalSupply(), "this id do not exist");
        uint indexCategorie = CategoryById[_tokenId];
        require(ownerOf(_tokenId) == msg.sender,  "not owner of this NFT");
        require(RoyaltiesClaimablePerCategory[indexCategorie] > 0, "No Rewards Yet");
        require( RoyaltiesClaimedPerId[_tokenId] < RoyaltiesClaimablePerCategory[indexCategorie] , "You already claimed your reward");
        uint claimableReward = RoyaltiesClaimablePerCategory[indexCategorie] - RoyaltiesClaimedPerId[_tokenId];
        bool success = contractERC20(usdc).transfer(msg.sender, claimableReward);
        require(success, "Could not transfer token. Missing approval?");
        RoyaltiesClaimedPerId[_tokenId] = RoyaltiesClaimablePerCategory[indexCategorie];
    }

    /**
    * @notice claim all rewards for holders
    *
    *Use enumerable properties to display Ids 
    */
    function claimMultipleRoyalties() external  {
        require(balanceOf(msg.sender) > 0, "you do not posess this nft");
        uint sum;
        for(uint i = 0; i < balanceOf(msg.sender); i ++){
            uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
            uint indexCategorie = CategoryById[tokenId];
            if (RoyaltiesClaimedPerId[tokenId] < RoyaltiesClaimablePerCategory[indexCategorie] && RoyaltiesClaimablePerCategory[indexCategorie] > 0 ){
                uint claimableReward = RoyaltiesClaimablePerCategory[indexCategorie] - RoyaltiesClaimedPerId[tokenId];
                sum += claimableReward;
                RoyaltiesClaimedPerId[tokenId] = RoyaltiesClaimablePerCategory[indexCategorie];
            }
        }
        require(sum > 0, "you already claimed all your rewards");
        bool success = contractERC20(usdc).transfer(msg.sender, sum);
        require(success, "Could not transfer token. Missing approval?");
    }

    /**
    * @notice Withdraw for owner
    *
    */
    function withdraw() external payable onlyInvestor {
        (bool success1, ) = payable(investor).call{value: ((msg.value * percentageInvestor) / 100)}("");
		require(success1);
        (bool success2, ) = payable(artist).call{value: (msg.value * percentageArtist) / 100}("");
		require(success2);
    }

    /**
    * @notice Withdraw
    *
    */
    function emergencyWithdraw(address erc20Token) external onlyInvestor {
        contractERC20(erc20Token).transfer(investor, contractERC20(erc20Token).balanceOf(address(this)) * percentageInvestor / 100); 
        contractERC20(erc20Token).transfer(artist, contractERC20(erc20Token).balanceOf(address(this)) * percentageArtist / 100);
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
    function addCategory(string memory _categories, string memory _baseUri, uint _price, uint _maxSupply, uint _percentages) external onlyInvestor {
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
    * @param categoryId id of the category you want to remove
    */
    function removeCategory(uint256 categoryId) external onlyInvestor {
        require(categories.length > categoryId, "Index is too high");
        delete categories[categoryId];
    }

    /**
    * @notice pause the contract
    */
    function setPaused() external onlyInvestor {
        _pause();
    }

    /**
    * @notice unpause the contract
    */
    function setUnPaused() external onlyInvestor {
        _unpause();
    }

    /**
    * @notice set the artist percentage
    */
    function setArtistPercentage(uint _percentageArtist) external onlyInvestor {
        percentageArtist = _percentageArtist;
    }

    /**
    * @notice set the investor percentage
    */
    function setInvestorPercentage(uint _percentageInvestor) external onlyInvestor {
        percentageInvestor = _percentageInvestor;
    }

    /**
    * @notice set artist percentage for opensea
    */
    function setArtistPercentageOpensea(uint _percentageArtistOpensea) external onlyInvestor {
        percentageArtistOpensea = _percentageArtistOpensea;
    }

    /**
    * @notice set investor percentage for opensea
    */
    function setInvestorPercentageOpensea(uint _percentageInvestorOpensea) external onlyInvestor {
        percentageInvestorOpensea = _percentageInvestorOpensea;
    }


    /**
    * @notice set start date
    */
    function setStartDate(uint _startDate) external onlyInvestor {
        startDate = _startDate;
    }

    /**
    * @notice get price of a category
    * @param categoryId id of the category you want to get the price
    */
    function getPriceByCategory(uint categoryId) external view returns(uint) {
        return categories[categoryId].price;
    }

    /**
    * @notice get total rewards
    */
    function getRewardsByTokenId(uint _tokenId) external view returns(uint) {
        uint indexCategorie = CategoryById[_tokenId];
        uint claimableReward = RoyaltiesClaimablePerCategory[indexCategorie] - RoyaltiesClaimedPerId[_tokenId];
        return claimableReward;
    }


    /**
    * @notice get price usdc
    */
    function getPrice() public view  returns (uint256) {
        StructLib.Slot memory slot = IUniswapPrice(poolContract).slot0();
        uint256 sqrtPriceX96 = uint256(slot.sqrtPriceX96);
        return sqrtPriceX96;
    } 
}

