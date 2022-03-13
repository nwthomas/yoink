import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import chai from "chai";
import { ethers } from "hardhat";
import { solidity } from "ethereum-waffle";
const { expect } = chai;

chai.use(solidity);

describe("ProfilePicture", () => {
  let account1: SignerWithAddress;
  let account2: SignerWithAddress;
  let account3: SignerWithAddress;

  beforeEach(async () => {
    const [owner, second, third] = await ethers.getSigners();

    account1 = owner;
    account2 = second;
    account3 = third;
  });

  const getDeployedContract = async () => {
    const contractFactory = await ethers.getContractFactory("ProfilePicture");
    const contract = await contractFactory.deploy();

    return contract;
  };
});
