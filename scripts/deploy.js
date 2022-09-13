// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  _categories = ["gold", "diamond"];
  _baseUri = ["ipfs://cid/", "ipfs://cid/"];
  _price = [50, 100];
  _maxSupply = [3, 5];
  _percentages = [50, 50];
  _usdc = 0x2791bca1f2de4661ed88a30c99a7a9449aa84174;
  _investor = 0x39f5e8c23f1a7565476b8f851c0a23911e3f6cc2;
  _artist = 0x39f5e8c23f1a7565476b8f851c0a23911e3f6cc2;

  const Contract = await hre.ethers.getContractFactory("ERC721Token");
  const contract = await Contract.deploy(
    _categories,
    _baseUri,
    _price,
    _maxSupply,
    _percentages,
    _usdc,
    _investor,
    _artist
  );

  await contract.deployed();

  console.log("deployed:", contract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
