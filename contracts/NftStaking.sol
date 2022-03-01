// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract Staking is ERC1155Holder {
    uint private nftId;
    uint private month = 2592000;
    uint private plan;
    uint private apr;
    IERC1155 private Token;

    constructor(address tokenAddress) {
        Token = IERC1155(tokenAddress);
    }

    struct stakedNft {
        uint nftId;
        address nftContractAddress;
        uint nftPrice;
        address staker;
        uint tokenId;
        uint releaseTime;
        uint plan;
        uint finalEarnings;
        uint PlanTimeInMonths;
        uint completedPaymentCycles;
    }

    mapping(address =>uint[]) private usersNft; 
    mapping(uint => stakedNft)public NFT;
    mapping(address => uint) private balances;


    function stakeNftFor18Months(address nftContractAddress,uint price,uint tokenId) public {
        uint months =18;
        uint time = months * month;
        plan =1;
        stakeNft(nftContractAddress, price, tokenId, time,plan, months);
    }

    function stakeNftFor24Months(address nftContractAddress,uint price,uint tokenId) public {
        uint months = 24;
        uint time = months * month;
        plan = 2;
        stakeNft(nftContractAddress, price, tokenId, time, plan,months);
    }

    function stakeNftFor36Months(address nftContractAddress,uint price,uint tokenId) public {
        uint months = 36;
        uint time = months * month;
        plan = 3;
        stakeNft(nftContractAddress, price, tokenId, time, plan,months);
    }

    function reddemNft(uint nftId) public{
        
        address user = NFT[nftId].staker;
        require(user == msg.sender);
        uint timeRemaining = NFT[nftId].releaseTime;
        require(block.timestamp >= timeRemaining);
        address nftContract = NFT[nftId].nftContractAddress;
        uint id = NFT[nftId].tokenId;
        IERC1155(nftContract).safeTransferFrom(address(this),msg.sender,id,1,"");  
    }

    function ReddemRewards() public {
        allocateReward();
        uint amount = balances[msg.sender];
        require(amount > 0);
        Token.safeTransferFrom(address(this),msg.sender,0,amount,"");
        balances[msg.sender] -= amount;
    }
    

    function stakeNft(address nftContractAddress,uint price,uint tokenId,uint time,uint stakingPlan,uint months) internal {
        require(IERC1155(nftContractAddress).balanceOf(msg.sender, tokenId) >= 1);
        IERC1155(nftContractAddress).safeTransferFrom(msg.sender,address(this),tokenId,1,"");
        if(usersNft[msg.sender].length>=1){
            nftId++;
            uint plan = 4;
            uint finalEarning = calculateRewardsForAMonth(price,plan) * months ;
            uint releaseTime = block.timestamp + time;
            NFT[nftId] = stakedNft(
                nftId,
                nftContractAddress,
                price,
                msg.sender,
                tokenId,
                releaseTime,
                plan,
                finalEarning,
                months,
                0
            );
            usersNft[msg.sender].push(nftId);
        }
        else{
            nftId++;
            uint releaseTime = block.timestamp + time;
            uint finalEarning = calculateRewardsForAMonth(price,stakingPlan) * months ;
            NFT[nftId] = stakedNft(
                nftId,
                nftContractAddress,
                price,
                msg.sender,
                tokenId,
                releaseTime,
                stakingPlan,
                finalEarning,
                months,
                0
            );
            usersNft[msg.sender].push(nftId);
        }   
    }

    function calculateRewardsForAMonth (uint price, uint stakingPlan) internal returns(uint) {
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

        uint earning = monthlyEarning(apr, price);
        return earning;
    }

    function monthlyEarning (uint Apr,uint price) internal returns(uint){
        return Apr * price /12000;
    }

    function allocateReward() internal {
        uint length = usersNft[msg.sender].length;
        for(uint i =1 ; i <= length ; i++) {
            if(NFT[i].finalEarnings > 0){
                if(block.timestamp > NFT[i].releaseTime){
                    balances[msg.sender] += NFT[i].finalEarnings;
                    NFT[i].finalEarnings = 0;
                }
                else{ 
                    uint completedPayment = NFT[i].completedPaymentCycles;
                    uint time = NFT[i].releaseTime;
                    uint cycles = NFT[i].PlanTimeInMonths;
                    uint cyclesLeft = (time - block.timestamp)/month;
                    uint cyclesCompleted = cycles - cyclesLeft;
                    uint pendingPayment = cyclesCompleted - completedPayment;
                    uint price = NFT[i].nftPrice;
                    uint currentPlan = NFT[i].plan; 
                    uint paymentPerCycle = calculateRewardsForAMonth(price,currentPlan);
                    uint amount = paymentPerCycle * pendingPayment;

                    if(amount > 0){
                        amount -= paymentPerCycle;
                    }
                    balances[msg.sender]  += amount;
                    NFT[i].finalEarnings  -= amount;
                    NFT[i].completedPaymentCycles += pendingPayment;
                }
            }
        }   
    }    
}