// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

contract GameReporter {
    event Report(
        address indexed sender,  
        uint32 startTs, 
        uint32 duration, 
        uint32 couponAmount, 
        uint32 treasureAmount, 
        bool won
    );

    function report(
        uint32 startTs, 
        uint32 duration, 
        uint32 couponAmount, 
        uint32 treasureAmount, 
        bool won
    ) external {
        emit Report(msg.sender, startTs, duration, couponAmount, treasureAmount, won);
    }
}