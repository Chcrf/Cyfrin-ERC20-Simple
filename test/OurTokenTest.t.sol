// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest  is Test{
    OurToken public otk;
    DeployOurToken public dot;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;
    function setUp() public {
        dot = new DeployOurToken();
        otk = dot.run();

        vm.prank(msg.sender);
        otk.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assert(otk.balanceOf(bob) == STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;
        //Bob approves alice to spend tokens on his behalf
        vm.prank(bob);
        otk.approve(alice, initialAllowance);

        vm.prank(alice);
        otk.transferFrom(bob, alice, transferAmount);

        assertEq(otk.balanceOf(alice), transferAmount);
        assertEq(otk.balanceOf(bob),STARTING_BALANCE-transferAmount);
    }

    function testTransfers() public {
        uint256 transferAmount = 100;

        vm.prank(msg.sender);
        otk.transfer(alice, transferAmount);
        assertEq(otk.balanceOf(alice), transferAmount);
        assertEq(otk.balanceOf(msg.sender), dot.INITIAL_SUPPLY() - STARTING_BALANCE - transferAmount);

        vm.prank(msg.sender);
        otk.transfer(bob, transferAmount);
        assertEq(otk.balanceOf(bob), STARTING_BALANCE+transferAmount);
        assertEq(otk.balanceOf(address(msg.sender)), dot.INITIAL_SUPPLY() - STARTING_BALANCE - (transferAmount * 2));

        vm.prank(bob);
        otk.approve(msg.sender, transferAmount);

        vm.prank(msg.sender);
        otk.transferFrom(bob, alice, transferAmount);
        assertEq(otk.balanceOf(bob), STARTING_BALANCE);
        assertEq(otk.balanceOf(alice), transferAmount * 2);
    }


}