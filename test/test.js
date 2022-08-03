const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const ERC20ABI = require("./ERC20.json");

const usdc = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48";

describe("ERC721Token", function () {
  before(async function () {
    [this.owner, this.addr1, this.addr2, this.addr3, ...this.addrs] =
      await ethers.getSigners();
  });

  it("should not deploy if the sum of percentages is not equal to 100%", async function () {
    _categories = ["gold", "diamond"];
    _baseUri = ["ipfs://cid/", "ipfs://cid/"];
    _price = [50, 100];
    _maxSupply = [3, 5];
    _percentages = [30, 50];
    contract = await hre.ethers.getContractFactory("ERC721Token");

    await expect(
      contract.deploy(_categories, _baseUri, _price, _maxSupply, _percentages)
    ).to.be.rejectedWith("The sum of percentages must be 100");
  });

  it("should deploy the smart contract", async function () {
    _categories = ["gold", "diamond"];
    _baseUri = ["ipfs://cid/", "ipfs://cid/"];
    _price = [50, 100];
    _maxSupply = [3, 5];
    _percentages = [50, 50];
    contract = await hre.ethers.getContractFactory("ERC721Token");

    this.deployedContract = await contract.deploy(
      _categories,
      _baseUri,
      _price,
      _maxSupply,
      _percentages
    );
  });

  it("it should mint first category", async function () {
    let price = await this.deployedContract.categories(0);
    price = price[2];
  });
});
