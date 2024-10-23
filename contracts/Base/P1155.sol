// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (P721.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Utility/TransferHelper.sol";
import "./PExtendable1155.sol";

/**
 * @dev 0xPioneer general sft token
 */
contract P1155 is PExtendable1155 {

    // proxy implementation do not use constructor, use initialize instead
    constructor() payable {}
    
    function initialize() external initOnce {
        _minter = msg.sender;
        _owner = msg.sender;
    }
    
    function init1155(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address codec
    ) external initOnceStep(2) {
        require(msg.sender == _owner, "P1155: FORBIDDEN");

        __chain_initialize_PExtendable1155(
            name, 
            symbol, 
            baseURI, 
            codec,
            500 // 5% royalties
        );
    }
    
    function setMinter(address minter) external {
        require(msg.sender == _owner, "P1155: FORBIDDEN");

        _minter = minter;
    }

    function setCodec(address codec) external {
        require(msg.sender == _owner, "P1155: FORBIDDEN");

        _codec = codec;
    }

    function transferERC20(address erc20) external {
        require(msg.sender == _owner, "P1155: FORBIDDEN");

        uint256 amount = IERC20(erc20).balanceOf(address(this));
        if(amount > 0) {
            TransferHelper.safeTransfer(erc20, msg.sender, amount);
        }
    }
    function transferETH() external {
        require(msg.sender == _owner, "P1155: FORBIDDEN");

        // send eth
        (bool sent, ) = msg.sender.call{value:address(this).balance}("");
        require(sent, "P1155: transfer error");
    }
}