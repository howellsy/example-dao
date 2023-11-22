// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {Timelock} from "../src/Timelock.sol";

contract MyGovernorTest is Test {
    MyGovernor public governor;
    Box public box;
    GovToken public govToken;
    Timelock public timelock;

    address public VOTER = makeAddr("voter");
    uint256 public constant INITIAL_SUPPLY = 100 ether;

    address[] public proposers;
    address[] public executors;
    uint256[] values;
    bytes[] calldatas;
    address[] targets;

    uint256 public constant MIN_DELAY = 3600; // 1 hour until a proposal can be executed (after it has been queued)
    uint256 public constant VOTING_DELAY = 7200; // 1 day until voting can start
    uint256 public constant VOTING_PERIOD = 50400; // 1 week

    function setUp() public {
        govToken = new GovToken();
        govToken.mint(VOTER, INITIAL_SUPPLY);

        vm.prank(VOTER);
        govToken.delegate(VOTER);
        timelock = new Timelock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(govToken, timelock);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, VOTER);

        box = new Box();
        box.transferOwnership(address(timelock));
    }

    function testCannotUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }

    function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 123;
        string memory description = "Store 123 in Box";
        bytes memory encodedFunctionCall = abi.encodeWithSelector(box.store.selector, valueToStore);

        values.push(0);
        calldatas.push(encodedFunctionCall);
        targets.push(address(box));

        // Make a proposal to the DAO
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        // Vote on the proposal
        string memory reason = "I really like this proposal";
        uint8 voteType = 1; // VoteType.For
        vm.prank(VOTER);
        governor.castVoteWithReason(proposalId, voteType, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        // Queue the TX
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);

        // Execute the TX
        governor.execute(targets, values, calldatas, descriptionHash);

        assert(box.getNumber() == valueToStore);
    }
}
