// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (KCoin20Minter.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../Base/PCapped20.sol";
import "../Utility/TransferHelper.sol";

contract PioneerTokenMinePool is 
    Context, 
    AccessControl
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event PioneerTokenMinePoolSend(address indexed userAddr, address indexed caller, uint256 value, bytes reason);

    uint256 public P101_PER_BLOCK; 

    uint256 public P101_TOTAL_OUTPUT;

    uint256 public P101_LIQUIDITY;
    uint256 public P101_LAST_OUTPUT_BLOCK;

    address public _PioneerToken;
    
    constructor(address PioneerToken, uint256 perblock) {
        require(perblock > 0, "PioneerTokenMinePool: per block must >0");

        P101_PER_BLOCK = perblock;
        P101_LAST_OUTPUT_BLOCK = block.number;
        _PioneerToken = PioneerToken;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function _output() internal {
        if(P101_LAST_OUTPUT_BLOCK >= block.number){
            return;
        }

        uint256 output = (block.number - P101_LAST_OUTPUT_BLOCK) * P101_PER_BLOCK;

        if(P101_TOTAL_OUTPUT < 25000000 * 10**18 && P101_TOTAL_OUTPUT + output >= 25000000 * 10**18) {
            uint256 output1 = 25000000 * 10**18 - P101_TOTAL_OUTPUT;
            uint256 output1blocks = output1 / P101_PER_BLOCK;

            P101_PER_BLOCK = P101_PER_BLOCK * 3 / 5;
            output = output1 + (block.number - P101_LAST_OUTPUT_BLOCK - output1blocks) * P101_PER_BLOCK;
        }
        else if(P101_TOTAL_OUTPUT < 40000000 * 10**18 && P101_TOTAL_OUTPUT + output >= 40000000 * 10**18) {
            uint256 output1 = 40000000 * 10**18 - P101_TOTAL_OUTPUT;
            uint256 output1blocks = output1 / P101_PER_BLOCK;

            P101_PER_BLOCK = P101_PER_BLOCK * 1 / 3;
            output = output1 + (block.number - P101_LAST_OUTPUT_BLOCK - output1blocks) * P101_PER_BLOCK;
        }

        P101_LAST_OUTPUT_BLOCK = block.number;
        P101_LIQUIDITY += output;
        P101_TOTAL_OUTPUT += output;
    }

    function send(address userAddr, uint256 value, bytes memory reason) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "PioneerTokenMinePool: must have minter role");

        if(value > P101_LIQUIDITY) {
            _output();
        }

        require(P101_LIQUIDITY >= value, "PioneerTokenMinePool: short of liquidity");
        require(PCapped20(_PioneerToken).balanceOf(address(this)) >= value, "PioneerTokenMinePool: insufficient PioneerToken");

        P101_LIQUIDITY -= value;
        TransferHelper.safeTransfer(_PioneerToken, userAddr, value);

        emit PioneerTokenMinePoolSend(userAddr, _msgSender(), value, reason);
    }
}