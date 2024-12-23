// SPDX-License-Identifier: MIT
// Metaline Contracts (MockTPO.sol)

pragma solidity ^0.8.0;

import "../Interface/TokenPriceOracle.sol";

contract MockTPO is TokenPriceOracle {

    // returns 18 decimal usd price, token usd value = token count * retvalue / 100000000;
    function getERC20TokenUSDPrice(address tokenAddr) external pure override returns(uint256) {
        tokenAddr;
        return 100000000;
    }
}