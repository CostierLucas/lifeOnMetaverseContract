// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const baseUriGold = "ipfs://cid";
  const baseUriPlatinum = "ipfs://cid";
  const baseUriDiamond = "ipfs://cid";
  const maxSupplyGold = 3;
  const maxSupplyPlatinum = 3;
  const maxSupplyDiamond = 3;
  const priceGold = 1;
  const pricePlatinum = 1;
  const priceDiamond = 1;

  const Contract = await hre.ethers.getContractFactory("ERC721Token");
  const contract = await Contract.deploy(
    baseUriGold,
    baseUriPlatinum,
    baseUriDiamond,
    maxSupplyGold,
    maxSupplyPlatinum,
    maxSupplyDiamond,
    priceGold,
    pricePlatinum,
    priceDiamond
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
