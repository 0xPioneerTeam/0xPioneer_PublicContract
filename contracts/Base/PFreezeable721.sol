// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (PFreezeable721.sol)

pragma solidity ^0.8.0;

import "../Base/P721.sol";

/**
 * @dev 0xPioneer freezeable nft token
 */
contract PFreezeable721 is P721 {

    event NFTFreeze(uint256 indexed tokenId, bool freeze);

    mapping(uint256 => bool) private _nftFreezed; // tokenid => is freezed

    function freeze(uint256 tokenId) external {
        require(msg.sender == _minter, "PFreezeable721: FORBIDDEN");

        _nftFreezed[tokenId] = true;

        emit NFTFreeze(tokenId, true);
    }

    function unfreeze(uint256 tokenId) external {
        require(msg.sender == _minter, "PFreezeable721: FORBIDDEN");

        delete _nftFreezed[tokenId];

        emit NFTFreeze(tokenId, false);
    }
    
    function notFreezed(uint256 tokenId) public view returns (bool) {
        return !_nftFreezed[tokenId];
    }
    function isFreezed(uint256 tokenId) public view returns (bool) {
        return _nftFreezed[tokenId];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(notFreezed(tokenId), "PFreezeable721: FORBIDDEN");
        super._beforeTokenTransfer(from, to, tokenId);
    }
}