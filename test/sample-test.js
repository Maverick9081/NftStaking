const { expect } = require("chai");
const { ethers } = require("hardhat");
let nft
let staker

beforeEach(async function () {

  const [owner, add1,add2] = await ethers.getSigners();

    const Nft = await ethers.getContractFactory("NFT");
    nft = await Nft.deploy();
    nftAddress = nft.address;

    const Staker = await ethers.getContractFactory("Staking");
    staker = await Staker.connect(owner).deploy(nftAddress);
    stakerAddress = staker.address;

    await nft.connect(owner).safeTransferFrom(owner.address,stakerAddress,0,100000,"0x00");
    await nft.mint(add1.address,1,2);
    await nft.connect(add1).setApprovalForAll(staker.address,true);
})


describe("Stakes the nft into the contract",async function(){

  it("The staked NFT is stored in the contract", async function(){
    
    const [owner, add1,add2] = await ethers.getSigners();
    await staker.connect(add1).stakeNftFor18Months(nftAddress,5000,1);
    expect(await nft.balanceOf(stakerAddress,1)).to.equal("1");
    expect(await nft.balanceOf(add1.address,1)).to.equal("1");
  })

   


})
