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
    * @param _categories categories of the token
    * @param _baseUri base URI of the token
    * @param _price price of the token
    * @param _maxSupply maximum supply of the token
    * @param _counterSupply counter supply of the token
    * @param _percentages percentages of the token
    **/
    function deployERC721(string[] memory _categories, string[] memory _baseUri, uint[] memory _price, uint[] memory _maxSupply, uint[] memory _counterSupply, uint[] memory _percentages) public returns (address) {
        ERC721Token t = new ERC721Token(_categories, _baseUri, _price, _maxSupply, _counterSupply, _percentages);
        tokens.push(t);
        indexToContract[tokens.length - 1] = address(t);
        indexToOwner[tokens.length - 1] = tx.origin;
        emit ERC721Created(msg.sender,address(t));
        return address(t);
    }
}