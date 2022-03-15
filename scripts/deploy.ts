import { ethers } from "hardhat";

async function main() {
  const GimmeTokenContractFactory = await ethers.getContractFactory(
    "GimmeToken"
  );

  // Update these with values before deploying
  const name = ""; // Example: "Uniswap"
  const symbol = ""; // Example: "UNI"
  const mintingFee = "0"; // Example: ethers.utils.parseEther("0.01");
  const firstTokenMetadataURI = "https://www.testing.com"; // Example: https://www.<your domain>.com/metadata.json

  const gimmeToken = await GimmeTokenContractFactory.deploy(
    name,
    symbol,
    mintingFee,
    firstTokenMetadataURI
  );

  await gimmeToken.deployed();
  console.log("GimmeToken deployed to:", gimmeToken.address);
  console.log(
    "First NFT OpenSea URL: ",
    `https://testnets.opensea.io/assets/${gimmeToken.address}/1`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
