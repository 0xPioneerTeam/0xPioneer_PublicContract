// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface TokenPriceOracle {
    // returns 8 decimal usd price, token usd value = token count * retvalue / 100000000;
    function getERC20TokenUSDPrice(address tokenAddr) external returns(uint256);
}