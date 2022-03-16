import { ethers } from "hardhat";

async function main() {
  const YoinkContractFactory = await ethers.getContractFactory("Yoink");

  // Update these with values before deploying
  const name = ""; // Example: "Uniswap"
  const symbol = ""; // Example: "UNI"
  const mintingFee = "0"; // Example: ethers.utils.parseEther("0.01");
  const firstTokenMetadataURI = "https://www.testing.com"; // Example: https://www.<your domain>.com/metadata.json

  const yoink = await YoinkContractFactory.deploy(
    name,
    symbol,
    mintingFee,
    firstTokenMetadataURI
  );

  await yoink.deployed();
  console.log("Yoink deployed to:", yoink.address);
  console.log(
    "First NFT OpenSea URL: ",
    `https://testnets.opensea.io/assets/${yoink.address}/1`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
