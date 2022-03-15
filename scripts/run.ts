import { ethers } from "hardhat";

async function main() {
  const GimmeTokenContractFactory = await ethers.getContractFactory(
    "GimmeToken"
  );

  // Update these with values before deploying
  const name = ""; // Example: "Uniswap"
  const symbol = ""; // Example: "UNI"
  const mintingFee = ethers.utils.parseEther("0.1"); // Example: ethers.utils.parseEther("0.05");
  const firstTokenMetadataURI = "https://www.testing.com"; // Example: https://www.<your domain>.com/metadata.json

  const gimmeToken = await GimmeTokenContractFactory.deploy(
    name,
    symbol,
    mintingFee,
    firstTokenMetadataURI
  );

  await gimmeToken.deployed();
  console.log("GimmeToken deployed to:", gimmeToken.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
