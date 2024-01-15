// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test{
    uint256 number = 1;
    FundMe public fundMe;
    HelperConfig public helperConfig;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp()external {
       //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
       DeployFundMe deployFundMe = new DeployFundMe();
       fundMe = deployFundMe.run();
       vm.deal(USER, STARTING_BALANCE);
    }
    
    function testMinimumDollarIsFive() public{
       assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function testOwnerIsMsgSender() public{
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        console.log(address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }
    function testPriceFeedVersionIsAccurate() public{
        uint version = fundMe.getVersion();
        assertEq(version, 4);
    }
    // function testPriceFeedIsSetCorrectly() public{
    //     address retrievedPriceFeed = address(fundMe.getPriceFeed());
    //     address expectedPriceFeed = helperConfig.activeNetworkConfig();
    //     console.log(retrievedPriceFeed);
    //     console.log(expectedPriceFeed);
    //     assertEq(retrievedPriceFeed,expectedPriceFeed);

    // }
    
    function testFundFailWithoutEnoughEth() public{
        vm.expectRevert();//tells the next line should revert
        //assert this tx fails
        fundMe.fund();
    }
    function testUpdatesFundedDataStructure() public{
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
    function testAddsFunderToArrayOfFunders() public{
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);

    }
    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funded{
        //First we fund the contract by: WE USED THE MODIFIER FUNDED
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }
    function testWithdrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance+startingOwnerBalance,endingOwnerBalance);
    }
    function testWithdrawFromMultipleFunders() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i= startingFunderIndex; i<numberOfFunders; i++){
            //vm.prank new address
            //vm.deal new address
            //address()
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            //fund the fundME
            uint256 startingOwnerBalance = fundMe.getOwner().balance;
            uint256 startingFundMeBalance = address(fundMe).balance;
            //Assert
            vm.startPrank(fundMe.getOwner());
            fundMe.withdraw();
            vm.stopPrank();
            //Act
            assert(address(fundMe).balance==0);
            assert(startingFundMeBalance+startingOwnerBalance == fundMe.getOwner().balance);
        }

    }
}