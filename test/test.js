const { expect } = require("chai");

describe("ERC721Token", function () {
  before(async function () {
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
  });

  it("should deploy ERC20", async function () {
    contract = await hre.ethers.getContractFactory("LifeToken");
    deployedContractErc = await contract.deploy();
  });

  it("should not deploy the smart contract : sum percentages not equal 100% ", async function () {
    _categories = ["gold", "diamond"];
    _baseUri = ["ipfs://cid/", "ipfs://cid/"];
    _price = [50, 100];
    _maxSupply = [3, 5];
    _percentages = [40, 50];
    contract = await hre.ethers.getContractFactory("ERC721Token");

    await expect(
      contract.deploy(
        _categories,
        _baseUri,
        _price,
        _maxSupply,
        _percentages,
        deployedContractErc.address
      )
    ).to.be.revertedWith("The sum of percentages must be 100");
  });

  it("should not deploy the smart contract : arrays don't have the same lenght", async function () {
    _categories = ["gold", "diamond"];
    _baseUri = ["ipfs://cid/", "ipfs://cid/"];
    _price = [50, 100, 200];
    _maxSupply = [3, 5];
    _percentages = [40, 50];
    contract = await hre.ethers.getContractFactory("ERC721Token");

    await expect(
      contract.deploy(
        _categories,
        _baseUri,
        _price,
        _maxSupply,
        _percentages,
        deployedContractErc.address
      )
    ).to.be.revertedWith("All arrays must have the same length");
  });

  it("should deploy the smart contract", async function () {
    _categories = ["gold", "diamond"];
    _baseUri = ["ipfs://cid/", "ipfs://cid/"];
    _price = [50, 100];
    _maxSupply = [3, 5];
    _percentages = [50, 50];
    contract = await hre.ethers.getContractFactory("ERC721Token");

    deployedContract = await contract.deploy(
      _categories,
      _baseUri,
      _price,
      _maxSupply,
      _percentages,
      deployedContractErc.address
    );
  });

  it("should approve ERC20 token", async function () {
    await deployedContractErc
      .connect(owner)
      .approve(
        deployedContract.address,
        "200000000000000000000000000000000000000000000000000000000000000"
      );
  });

  it("should reverse mint because not enought usdc", async function () {
    await expect(
      deployedContract.connect(owner).mintUSDC(1, 1)
    ).to.be.revertedWith("Not enought USDC");
  });

  it("should mint ERC20 token", async function () {
    await deployedContractErc.connect(owner).mint("100000");
  });

  it("should approve ERC20 token", async function () {
    let allow = await deployedContractErc.allowance(
      owner.address,
      deployedContract.address
    );
  });

  it("should not mint : invalid id", async function () {
    await expect(
      deployedContract.connect(owner).mintUSDC(1, 4)
    ).to.be.revertedWith("Invalid category");
  });

  it("should pause contract", async function () {
    expect(await deployedContract.connect(owner).setPaused());
  });

  it("should not mint : contract paused", async function () {
    await expect(
      deployedContract.connect(owner).mintUSDC(1, 0)
    ).to.be.revertedWith("Pausable: paused");
  });

  it("should unpause contract", async function () {
    expect(await deployedContract.connect(owner).setUnPaused());
  });

  it("should not mint : Not enought supply", async function () {
    await expect(
      deployedContract.connect(owner).mintUSDC(4, 0)
    ).to.be.revertedWith("Not enought supply");
  });

  it("should mint", async function () {
    await deployedContract.connect(owner).mintUSDC(1, 1);
  });

  it("should mint multiples", async function () {
    await deployedContract.connect(owner).mintUSDC(2, 1);
  });

  it("should not send usdc if not the owner", async function () {
    await expect(
      deployedContract.connect(addr1).FundRoyalties(100)
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("should send usdc to contract", async function () {
    expect(await deployedContract.connect(owner).FundRoyalties(100));
  });
});
