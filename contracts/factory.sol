// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./nft.sol";

contract FactoryERC721 {

    ERC721Token[] public tokens; //an array that contains different ERC721 tokens deployed
    mapping(uint256 => address) public indexToContract; //index to contract address mapping
    mapping(uint256 => address) public indexToOwner; //index to ERC721 owner address

    event ERC721Created(address owner, address tokenContract); //emitted when ERC721 token is deployed

    /**
    * @notice Deploys a ERC721 token with given parameters - returns deployed address
    *
    * @param _baseUriGold Base URI for Gold token
    * @param _baseUriPlatinum Base URI for Platinum token
    * @param _baseUriDiamond Base URI for Diamond token
    * @param _MAX_SUPPLY_Gold Maximum supply of Gold token
    * @param _MAX_SUPPLY_Platinum Maximum supply of Platinum token
    * @param _MAX_SUPPLY_Diamond Maximum supply of Diamond token
    * @param _priceGold Price of Gold token
    * @param _pricePlatinum Price of Platinum token
    * @param _priceDiamond Price of Diamond token
    **/
    function deployERC721(string memory _baseUriGold, string memory _baseUriPlatinum, string memory _baseUriDiamond, uint _MAX_SUPPLY_Gold, uint _MAX_SUPPLY_Platinum, uint _MAX_SUPPLY_Diamond, uint _priceGold, uint _pricePlatinum, uint _priceDiamond) public returns (address) {
        ERC721Token t = new ERC721Token( _baseUriGold, _baseUriPlatinum, _baseUriDiamond, _MAX_SUPPLY_Gold, _MAX_SUPPLY_Platinum, _MAX_SUPPLY_Diamond, _priceGold, _pricePlatinum, _priceDiamond);
        tokens.push(t);
        indexToContract[tokens.length - 1] = address(t);
        indexToOwner[tokens.length - 1] = tx.origin;
        emit ERC721Created(msg.sender,address(t));
        return address(t);
    }
}