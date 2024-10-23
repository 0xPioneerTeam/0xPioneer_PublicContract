// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (PioneerSyCoin20.sol)

pragma solidity ^0.8.0;

import "../Utility/ProxyUpgradeable.sol";

// Pioneer Sync Coin token, proxy of PMintable20
contract PioneerSyCoin20 is ProxyUpgradeable {

    constructor(address impl) 
        payable 
        ProxyUpgradeable(impl)
    {

    }
}