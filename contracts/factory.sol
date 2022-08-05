// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./nft.sol";

contract FactoryERC721 {

    event Deployed(address addr, uint256 salt);

    function getBytecode(string[] memory _categories, string[] memory _baseUri, uint[] memory _price, uint[] memory _maxSupply, uint[] memory _percentages, address _usdc) public pure returns (bytes memory){
        bytes memory bytecode = type(ERC721Token).creationCode;
        return abi.encodePacked(bytecode, abi.encode( _categories,  _baseUri,  _price,  _maxSupply,  _percentages, _usdc));
    }
    
    function getAddress (bytes memory bytecode, uint _salt) public view returns (address){
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode))
            );
            return address(uint160(uint256(hash)));
    }

    function deploy(bytes memory bytecode, uint _salt) public payable {
        address addr;
        assembly{
            addr := create2(
                callvalue() // wei sent with current call, equal msg.value
            , add(bytecode, 0x20), // Actual code starts after skipping the first 32 bytes
            mload(bytecode)// Load the size of code contained in the first 32 bytes
            , _salt) 
            if iszero(extcodesize(addr)){
                revert(0, 0) //check if it is deployed
            }
        }
        emit Deployed( addr, _salt);
    }
}


