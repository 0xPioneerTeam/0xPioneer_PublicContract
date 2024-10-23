// SPDX-License-Identifier: MIT
// 0XPioneer Contracts (P721.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Utility/TransferHelper.sol";
import "./PExtendable721.sol";

/**
 * @dev 0xPioneer general nft token
 */
contract P721 is PExtendable721 {

    // proxy implementation do not use constructor, use initialize instead
    constructor() payable {}
    
    function initialize() external initOnce {
        _minter = msg.sender;
        _owner = msg.sender;
    }
    
    function init721(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address codec,
        uint256 idStart
    ) external initOnceStep(2) {
        require(msg.sender == _owner, "P721: FORBIDDEN");

        __chain_initialize_PExtendable721(
            name, 
            symbol, 
            baseURI, 
            codec,
            500, // 5% royalties
            idStart
        );
    }
    
    function setMinter(address minter) external {
        require(msg.sender == _owner, "P721: FORBIDDEN");

        _minter = minter;
    }

    function setCodec(address codec) external {
        require(msg.sender == _owner, "P721: FORBIDDEN");

        _codec = codec;
    }

    function mint(address to, bytes memory data) public returns(uint256) {
        require(msg.sender == _minter, "P721: FORBIDDEN");

        return _mintWithData(to, data);
    }

    function mintFixedId(address to, uint256 tokenId, bytes memory data) public returns(uint256) {
        require(msg.sender == _minter, "P721: FORBIDDEN");

        return _mintFixedIdWithData(to, tokenId, data);
    }

    function transferERC20(address erc20) external {
        require(msg.sender == _owner, "P721: FORBIDDEN");

        uint256 amount = IERC20(erc20).balanceOf(address(this));
        if(amount > 0) {
            TransferHelper.safeTransfer(erc20, msg.sender, amount);
        }
    }
    function transferETH() external {
        require(msg.sender == _owner, "P721: FORBIDDEN");

        // send eth
        (bool sent, ) = msg.sender.call{value:address(this).balance}("");
        require(sent, "P721: transfer error");
    }
}