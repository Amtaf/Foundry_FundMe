// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Interactions.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";


contract InteractionsTest is StdCheats,Test{

    FundMe public fundMe;
    
    uint256 constant SEND_VALUE = 0.01 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    address public constant USER = address(1);

    function setUp() external{
       DeployFundMe deployFundMe = new DeployFundMe();
       fundMe = deployFundMe.run();
       vm.deal(USER, STARTING_BALANCE);

    }

    function testUserCanFundInteractions() public{
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        // vm.prank(USER);
        // vm.deal(USER, 1e18);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        // address funder = fundMe.getFunder(0);
        // assertEq(funder, USER);
        assert(address(fundMe).balance ==0);
        
    }

}