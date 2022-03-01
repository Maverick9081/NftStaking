const { tasks } = require("hardhat/config");
const { getAccount, getEnvVariable } = require("./helpers");


task("deploy-ERC1155", "Deploys the ERC1155 contract").setAction(async function (taskArguments, hre) {
    const nftContractFactory = await hre.ethers.getContractFactory("NFT", getAccount());
    const nft = await nftContractFactory.deploy();
    console.log(`Contract deployed to address: ${nft.address}`);
});

task("deploy-nftStaker", "Deploys the ERC20 contract").setAction(async function (taskArguments, hre) {
    const stakingFactory = await hre.ethers.getContractFactory("Staking", getAccount());
    const staker = await stakingFactory.deploy(getEnvVariable("TOKEN_ADDRESS"));
    console.log(`Contract deployed to address: ${staker.address}`);
});