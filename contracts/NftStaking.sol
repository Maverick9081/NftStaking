// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract Staking is ERC1155Holder {
    uint private nftId;
    uint private month = 2592000;
    IERC1155 private Token;

    constructor(address tokenAddress) {
        Token = IERC1155(tokenAddress);
    }

    struct stakedNft {
        address nftContractAddress;
        uint nftPrice;
        address staker;
        uint tokenId;
        uint releaseTime;
        uint plan;
        uint finalEarnings;
    }

    mapping(address =>uint[]) private usersNft; 
    mapping(uint => stakedNft)public NFT;

    function stakeNft(address nftContractAddress,uint price,uint tokenId,uint months) public {
        require(IERC1155(nftContractAddress).balanceOf(msg.sender, tokenId) >= 1);
        require(months == 18 ||
                months== 24 ||
                months == 36);
        IERC1155(nftContractAddress).safeTransferFrom(msg.sender,address(this),tokenId,1,"");

            nftId++;
            uint plan = getPlan(months);
            uint finalEarning = calculateRewards(price,plan,months);
            uint releaseTime = block.timestamp + months * month;
            NFT[nftId] = stakedNft(
                nftContractAddress,
                price,
                msg.sender,
                tokenId,
                releaseTime,
                plan,
                finalEarning
            );
        usersNft[msg.sender].push(nftId);   
    }

     function unstakeNft(uint nftId) public{
        
        address user = NFT[nftId].staker;
        require(user == msg.sender);
        uint timeRemaining = NFT[nftId].releaseTime;
        require(block.timestamp >= timeRemaining);
        address nftContract = NFT[nftId].nftContractAddress;
        uint id = NFT[nftId].tokenId;
        IERC1155(nftContract).safeTransferFrom(address(this),msg.sender,id,1,"");
        uint amount = NFT[nftId].finalEarnings;
        Token.safeTransferFrom(address(this),msg.sender,0,amount,"");
    }

    function getPlan(uint months) internal  returns(uint){
        
        if(usersNft[msg.sender].length>=1){
            return 4;
        }
        if(months == 18){
            return 1;
        }
        if(months == 24){
            return 2;
        }
        if(months == 36){
            return 3;
        }    
    }

    function calculateRewards (uint price, uint stakingPlan,uint months) internal view returns(uint) {
        uint apr;
        if(stakingPlan == 1){
            apr = 50;
        }
        else if(stakingPlan == 2){
            apr = 100;
        }
        else if(stakingPlan == 3){
            apr = 150;
        }
        else if(stakingPlan == 4){
            apr = 125;
        }
        return months * apr *price/12000;
    }
}
