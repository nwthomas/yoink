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
    it("exempts an address if toggleExemptAddress is called", async () => {
      const contract = await getDeployedContract(deployArgs);

      let addressExemptionStatusTxn = await contract.exemptAddresses(
        account3.address
      );
      expect(addressExemptionStatusTxn).to.equal(false);

      await contract.toggleExemptAddresses([account3.address]);

      addressExemptionStatusTxn = await contract.exemptAddresses(
        account3.address
      );
      expect(addressExemptionStatusTxn).to.equal(true);
    });

    it("un-exempts an address with toggleExemptAddress", async () => {
      const contract = await getDeployedContract(deployArgs);

      await contract.toggleExemptAddresses([account3.address]);
      let addressExemptionStatusTxn = await contract.exemptAddresses(
        account3.address
      );
      expect(addressExemptionStatusTxn).to.equal(true);

      await contract.toggleExemptAddresses([account3.address]);
      addressExemptionStatusTxn = await contract.exemptAddresses(
        account3.address
      );
      expect(addressExemptionStatusTxn).to.equal(false);
    });

    it("emits an AddExemptAddress event", async () => {
      const contract = await getDeployedContract(deployArgs);

      const addExemptAddressTxn = await contract.toggleExemptAddresses([
        account2.address,
      ]);
      expect(addExemptAddressTxn)
        .to.emit(contract, "AddExemptAddress")
        .withArgs(account2.address);
    });

    it("emits a RemoveExemptAddress event", async () => {
      const contract = await getDeployedContract(deployArgs);

      await contract.toggleExemptAddresses([account2.address]);

      const removeExemptAddressTxn = await contract.toggleExemptAddresses([
        account2.address,
      ]);
      expect(removeExemptAddressTxn)
        .to.emit(contract, "RemoveExemptAddress")
        .withArgs(account2.address);
    });

    it("can toggle multiple addresses at once", async () => {
      const contract = await getDeployedContract(deployArgs);

      await contract.toggleExemptAddresses([account2.address]);
      await contract.toggleExemptAddresses([
        account1.address,
        account2.address,
        account3.address,
      ]);

      const [account1Status, account2Status, account3Status] =
        await Promise.all([
          contract.exemptAddresses(account1.address),
          contract.exemptAddresses(account2.address),
          contract.exemptAddresses(account3.address),
        ]);

      expect(account1Status).to.equal(true);
      expect(account2Status).to.equal(false);
      expect(account3Status).to.equal(true);
    });

    it("emits multiple events at once", async () => {
      const contract = await getDeployedContract(deployArgs);

      await contract.toggleExemptAddresses([account2.address]);
      const toggleExemptionTxn = await contract.toggleExemptAddresses([
        account1.address,
        account2.address,
        account3.address,
      ]);

      expect(toggleExemptionTxn)
        .to.emit(contract, "AddExemptAddress")
        .withArgs(account1.address);
      expect(toggleExemptionTxn)
        .to.emit(contract, "RemoveExemptAddress")
        .withArgs(account2.address);
      expect(toggleExemptionTxn)
        .to.emit(contract, "AddExemptAddress")
        .withArgs(account3.address);
    });

    it("allows toggling many times for same address", async () => {
      const contract = await getDeployedContract(deployArgs);
      let currentState = false;

      for (let i = 0; i < 100; i++) {
        const addressExemptionStatusTxn = await contract.exemptAddresses(
          account3.address
        );
        expect(addressExemptionStatusTxn).to.equal(currentState);

        await contract.toggleExemptAddresses([account3.address]);
        currentState = !currentState;
      }
    });
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
