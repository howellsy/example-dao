// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract Timelock is TimelockController {
    /**
     * @param minDelay How long to wait before executing a proposal after it has been queued.
     * @param proposers The list of addresses that are allowed to make new proposals.
     * @param executors The list of addresses that are allowed to execute proposals.
     */
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors)
        TimelockController(minDelay, proposers, executors, msg.sender)
    {}
}
