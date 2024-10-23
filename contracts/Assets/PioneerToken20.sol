// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (PioneerToken20.sol)

pragma solidity ^0.8.0;

import "../Utility/ProxyUpgradeable.sol";

// 0xPioneer 101 token, proxy of PCapped20
contract PioneerToken20 is ProxyUpgradeable {

    constructor(address impl) 
        payable 
        ProxyUpgradeable(impl)
    {

    }
}