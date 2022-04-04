import { ethers } from "hardhat";
// Importing with require statement as TS has a hard time with this dependency
const ethProvider = require("eth-provider");

async function main() {
  const frame = ethProvider("frame", {
    alchemyId: process.env.MAINNET_APP_SECRET_KEY,
  });
  const YoinkContractFactory = await ethers.getContractFactory("Yoink");

  // Update these with values before deploying
  const name = ""; // Example: "Uniswap"
  const symbol = ""; // Example: "UNI"
  const mintingFee = ethers.utils.parseEther("0.02"); // Example: ethers.utils.parseEther("0.01");
  const firstTokenMetadataURI = ""; // Example: https://www.<your domain>.com/metadata.json
  const exemptAddresses: string[] = []; // Array of addresses to exempt on deploy (can be empty)

  const deployTxn = await YoinkContractFactory.getDeployTransaction(
    name,
    symbol,
    mintingFee,
    firstTokenMetadataURI,
    exemptAddresses
  );

  deployTxn.from = (await frame.request({ method: "eth_requestAccounts" }))[0];

  const result = await frame.request({
    method: "eth_sendTransaction",
    params: [deployTxn],
  });

  console.log("Yoink deployed to:", result.address);
  console.log(
    "View address on OpenSea: ",
    `https://testnets.opensea.io/assets/${result.address}/1`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
