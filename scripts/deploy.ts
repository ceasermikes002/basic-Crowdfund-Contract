import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contract with the account:", deployer.address);

    const Crowdfunding = await ethers.getContractFactory("Crowdfunding");
    const crowdfundingContract = await Crowdfunding.deploy();

    await crowdfundingContract.waitForDeployment();

    console.log("Crowdfunding contract deployed at:", crowdfundingContract.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
