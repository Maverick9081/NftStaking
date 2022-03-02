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


describe("Staking",async function(){

  it("The staked NFT is stored in the contract", async function(){
    
    const [owner, add1,add2] = await ethers.getSigners();
    await staker.connect(add1).stakeNft(nftAddress,5000,1,36);
    expect(await nft.balanceOf(stakerAddress,1)).to.equal("1");
    expect(await nft.balanceOf(add1.address,1)).to.equal("1");
  })

  it("after unstaking the nft the rewards and nft are tranferred to user's account",async function(){

    const [owner, add1,add2] = await ethers.getSigners();
    await staker.connect(add1).stakeNft(nftAddress,5000,1,18);
    await staker.connect(add1).unstakeNft(1);
    expect(await nft.balanceOf(stakerAddress,1)).to.equal("0");
    expect(await nft.balanceOf(add1.address,1)).to.equal("2");
    expect(await nft.balanceOf(add1.address,0)).to.equal("375")
  })

  it("If a user stakes another time then the APR is restricted to 12.5%",async function(){

    const [owner, add1,add2] = await ethers.getSigners();
    await staker.connect(add1).stakeNft(nftAddress,5000,1,18);
    await staker.connect(add1).stakeNft(nftAddress,5000,1,18);
    await staker.connect(add1).unstakeNft(2);
    expect(await nft.balanceOf(add1.address,0)).to.equal("937");
  })
})
