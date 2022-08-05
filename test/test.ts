import { assert, expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers, network } from "hardhat";
import { BigNumber, Contract } from "ethers";

describe("ERC721Token", function () {
  let contract: any;
  let deployedContractErc: any;
  let deployedContract: any;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addr2: SignerWithAddress;
  let addr3: SignerWithAddress;
  let addrs: SignerWithAddress[];
  let _categories: string[];
  let _baseUri: string[];
  let _price: number[];
  let _maxSupply: number[];
  let _percentages: number[];
  let _artist: string;
  let _investor: string;

  before(async function () {
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    contract = await ethers.getContractFactory("LifeToken");
    deployedContractErc = await contract.deploy();
  });

  describe("Deploy not allowed", async function () {
    it("should not deploy the smart contract : sum percentages not equal 100% ", async function () {
      _categories = ["gold", "diamond"];
      _baseUri = ["ipfs://cid/", "ipfs://cid/"];
      _price = [50, 100];
      _maxSupply = [3, 5];
      _percentages = [40, 50];
      _artist = owner.address;
      _investor = addr1.address;
      contract = await ethers.getContractFactory("ERC721Token");

      await expect(
        contract.deploy(
          _categories,
          _baseUri,
          _price,
          _maxSupply,
          _percentages,
          deployedContractErc.address,
          _artist,
          _investor
        )
      ).to.be.revertedWith("The sum of percentages must be 100");
    });

    it("should not deploy the smart contract : arrays don't have the same lenght", async function () {
      _categories = ["gold", "diamond"];
      _baseUri = ["ipfs://cid/", "ipfs://cid/"];
      _price = [50, 100, 200];
      _maxSupply = [3, 5];
      _percentages = [40, 50];
      _artist = owner.address;
      _investor = addr1.address;
      contract = await ethers.getContractFactory("ERC721Token");

      await expect(
        contract.deploy(
          _categories,
          _baseUri,
          _price,
          _maxSupply,
          _percentages,
          deployedContractErc.address,
          _artist,
          _investor
        )
      ).to.be.revertedWith("All arrays must have the same length");
    });

    it("should deploy the smart contract", async function () {
      _categories = ["gold", "diamond"];
      _baseUri = ["ipfs://cid/", "ipfs://cid/"];
      _price = [50, 100];
      _maxSupply = [3, 5];
      _percentages = [50, 50];
      _artist = owner.address;
      _investor = addr1.address;
      contract = await ethers.getContractFactory("ERC721Token");

      deployedContract = await contract.deploy(
        _categories,
        _baseUri,
        _price,
        _maxSupply,
        _percentages,
        deployedContractErc.address,
        _artist,
        _investor
      );
    });
  });

  describe("ERC20 interaction", async function () {
    it("should approve ERC20 token", async function () {
      await deployedContractErc
        .connect(owner)
        .approve(
          deployedContract.address,
          "200000000000000000000000000000000000000000000000000000000000000"
        );
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
  });

  describe("Mint Token", async function () {
    it("should reverse mint because not enought usdc", async function () {
      await expect(
        deployedContract.connect(addr1).mintUSDC(1, 1)
      ).to.be.revertedWith("Not enought USDC");
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
  });

  describe("Fund Artist Royalties", async function () {
    it("should not send usdc if not the owner", async function () {
      await expect(
        deployedContract.connect(addr1).FundRoyalties(1000)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("should fail if 0 usdc send to contract", async function () {
      await expect(
        deployedContract.connect(owner).FundRoyalties(0)
      ).to.be.revertedWith("amount can't be 0");
    });

    it("should send usdc to contract", async function () {
      expect(await deployedContract.connect(owner).FundRoyalties(3000));
    });

    it("should increase claimable royalties", async function () {
      expect(
        await (
          await deployedContract.RoyaltiesClaimablePerCategory(0)
        ).toString()
      ).to.equal("500");
      expect(
        await (
          await deployedContract.RoyaltiesClaimablePerCategory(1)
        ).toString()
      ).to.equal("300");
    });
  });

  describe("Claim Artist Royalties", async function () {
    it("should fail if tokenId do not exists", async function () {
      await expect(deployedContract.claimRoyalties(100)).to.be.revertedWith(
        "this id do not exist"
      );
    });
    it("should fail if not owner of NFT", async function () {
      await expect(
        deployedContract.connect(addr1).claimRoyalties(0)
      ).to.be.revertedWith("not owner of this NFT");
    });
    it("should display the right amount before claimed", async function () {
      const RoyaltiesClaimed = await (
        await deployedContract.RoyaltiesClaimedPerId(0)
      ).toString();
      expect(RoyaltiesClaimed).to.equal("0");
    });
    it("should display the right amount after claimed", async function () {
      await expect(deployedContract.connect(owner).claimRoyalties(0));
      const RoyaltiesClaimable = await (
        await deployedContract.connect(owner).RoyaltiesClaimablePerCategory(1)
      ).toString();
      const RoyaltiesClaimed = await (
        await deployedContract.RoyaltiesClaimedPerId(0)
      ).toString();
      expect(RoyaltiesClaimed).to.equal(RoyaltiesClaimable);
    });
    it("should fail if reward already claimed", async function () {
      await expect(deployedContract.connect(owner).claimRoyalties(0));
      await expect(
        deployedContract.connect(owner).claimRoyalties(0)
      ).to.be.revertedWith("You already claimed your reward");
    });
  });

  describe("Claim Multiple Artist Royalties", async function () {
    it("should fail if not owner of any NFT", async function () {
      await expect(
        deployedContract.connect(addr3).claimMultipleRoyalties()
      ).to.be.revertedWith("you do not posess this nft");
    });

    it("should claim multiple royalties", async function () {
      await expect(deployedContract.connect(owner).claimMultipleRoyalties());
      await expect(deployedContract.connect(addr1).claimMultipleRoyalties());
    });
  });
});
