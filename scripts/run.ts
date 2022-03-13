import { ethers } from "hardhat";

async function main() {
  const ProfilePictureContractFactory = await ethers.getContractFactory(
    "ProfilePicture"
  );

  // Update these with values before running tests
  const name = ""; // Example: "Uniswap"
  const symbol = ""; // Example: "UNI"
  const mintingFee = "0"; // Example: ethers.utils.parseEther("0.01").toString();
  const firstTokenMetadataURI = ""; // Example: https://www.nathanthomas.dev/nathan-metadata.json

  const profilePicture = await ProfilePictureContractFactory.deploy(
    name,
    symbol,
    mintingFee,
    firstTokenMetadataURI
  );

  await profilePicture.deployed();
  console.log("ProfilePicture deployed to:", profilePicture.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
