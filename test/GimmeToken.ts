import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import chai from "chai";
import { ethers } from "hardhat";
import { solidity } from "ethereum-waffle";
const { expect } = chai;

chai.use(solidity);

type DeployArguments = {
  name: string;
  symbol: string;
  mintingFee: string;
  firstTokenURL: string;
};

describe("GimmeToken", () => {
  let account1: SignerWithAddress;
  let account2: SignerWithAddress;
  let account3: SignerWithAddress;

  const deployArgs = {
    name: "GimmeToken",
    symbol: "GIMME",
    mintingFee: ethers.utils.parseEther("0.01").toString(),
    firstTokenURL: "https://www.nathanthomas.dev/nathan-token.json",
  };

  beforeEach(async () => {
    const [owner, second, third] = await ethers.getSigners();

    account1 = owner;
    account2 = second;
    account3 = third;
  });

  const getDeployedContract = async ({
    name,
    symbol,
    mintingFee,
    firstTokenURL,
  }: DeployArguments) => {
    const contractFactory = await ethers.getContractFactory("GimmeToken");
    const contract = await contractFactory.deploy(
      name,
      symbol,
      mintingFee,
      firstTokenURL
    );

    return contract;
  };

  describe("deploys", () => {
    it("assigns variables on deploy", async () => {
      const contract = await getDeployedContract(deployArgs);

      const nameTxn = await contract.name();
      expect(nameTxn).to.equal("GimmeToken");

      const symbolTxn = await contract.symbol();
      expect(symbolTxn).to.equal("GIMME");

      const mintingFeeTxn = await contract.mintingFee();
      expect(mintingFeeTxn).to.equal(
        ethers.utils.parseEther("0.01").toString()
      );
    });

    it("mints first NFT on deploy with correct metadata", async () => {
      const contract = await getDeployedContract(deployArgs);

      const ownerOfTxn = await contract.ownerOf(1);
      expect(ownerOfTxn).to.equal(account1.address);

      const firstTokenTxn = await contract.tokenURI(1);
      expect(firstTokenTxn).to.equal(deployArgs.firstTokenURL);
    });

    it("allows an empty string for first token URI", async () => {
      deployArgs.firstTokenURL = "";
      const contract = await getDeployedContract(deployArgs);

      const firstTokenTxn = await contract.tokenURI(1);
      expect(firstTokenTxn).to.equal("");
    });
  });

  describe("exempt addresses", () => {
    // finish
  });

  describe("mint NFT", () => {
    // finish
  });

  describe("updateTokenURI", () => {
    // finish
  });

  describe("minting fee", () => {
    // finish
  });

  describe("withdrawing ether", () => {
    // finish
  });

  describe("ownership", () => {
    it("instantiates a new contract with owner", async () => {
      const contract = await getDeployedContract(deployArgs);
      const owner = await contract.owner();
      expect(owner).to.equal(account1.address);
    });

    it("transfers ownership", async () => {
      const contract = await getDeployedContract(deployArgs);
      const transferOwnershipTxn = await contract.transferOwnership(
        account2.address
      );
      expect(transferOwnershipTxn)
        .to.emit(contract, "OwnershipTransferred")
        .withArgs(account1.address, account2.address);
    });

    it("throws error when non-owner attempts transfer", async () => {
      const contract = await getDeployedContract(deployArgs);

      let error;
      try {
        await contract.connect(account2).transferOwnership(account2.address);
      } catch (newError) {
        error = newError;
      }

      expect(
        String(error).indexOf("Ownable: caller is not the owner") > -1
      ).to.equal(true);
    });

    it("renounces ownership", async () => {
      const contract = await getDeployedContract(deployArgs);
      const renounceOwnershipTxn = contract.renounceOwnership();
      expect(renounceOwnershipTxn)
        .to.emit(contract, "OwnershipTransferred")
        .withArgs(
          account1.address,
          "0x0000000000000000000000000000000000000000"
        );
    });

    it("throws error when non-owner attempts renouncing ownership", async () => {
      const contract = await getDeployedContract(deployArgs);

      let error;
      try {
        await contract.connect(account2).renounceOwnership();
      } catch (newError) {
        error = newError;
      }

      expect(
        String(error).indexOf("Ownable: caller is not the owner") > -1
      ).to.equal(true);
    });
  });
});
