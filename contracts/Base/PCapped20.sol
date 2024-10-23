// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (PCapped20.sol)

pragma solidity ^0.8.0;

import "./PBase20.sol";

contract PCapped20 is PBase20 {
    address public _owner;

    // proxy implementation do not use constructor, use initialize instead
    constructor() {}

    function initialize() external initOnce {
        _owner = msg.sender;
    }

    function initCapped20(
        string memory name_,
        string memory symbol_,
        uint256 cap_
    ) external initOnceStep(2) {
        require(msg.sender == _owner, "PCapped20: FORBIDDEN");

        __chain_initialize_PBase20(
            name_, 
            symbol_
        );

        _mint(msg.sender, cap_);
    }
}