// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (PExtendable1155.sol)

pragma solidity ^0.8.0;

import "../Interface/IERC2981Royalties.sol";
import "./PBase1155.sol";

abstract contract PExtendable1155 is 
    IERC2981Royalties,
    PBase1155
{
    event Extendable1155Modify(uint256 indexed id, bytes extendData);

    address public _minter;
    address public _owner;
    address public _codec;

    // erc2981 royalty fee, /10000
    uint256 public _royalties;
    address public _royalFeeAddr;

    mapping(uint256=>bytes) _extendDatas;

    // proxy implementation do not use constructor, use initialize instead
    constructor() payable {}
    
    function isOwner(address addr) public view returns(bool) {
        return _owner == addr;
    }

    function changeOwner(address newOwner) external {
        require(msg.sender == _owner, "PExtendable1155: FORBIDDEN");

        _owner = newOwner;
    }

    function __chain_initialize_PExtendable1155(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address codec,
        uint256 royalties
    ) internal onlyInitializing {

        _royalFeeAddr = _owner;
        _royalties = royalties;

        _codec = codec;

        __chain_initialize_P1155(baseURI, name, symbol);
    }

    /**
     * @dev update base token uri, See {IERC1155MetadataURI-uri}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function updateURI(string calldata newuri) public virtual {
        require(msg.sender == _owner, "PExtendable1155: FORBIDDEN");
        _setURI(newuri);
    }

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     *
     * See {ERC1155-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(msg.sender == _minter, "PExtendable1155: FORBIDDEN");

        _mint(to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        require(msg.sender == _minter, "PExtendable1155: FORBIDDEN");

        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC2981Royalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // set royalties
    function setRoyalties(uint256 royalties) external {
        require(msg.sender == _owner, "PExtendable1155: FORBIDDEN");
        _royalties = royalties;
    }

    /// @inheritdoc	IERC2981Royalties
    function royaltyInfo(uint256, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _royalFeeAddr;
        royaltyAmount = (value * _royalties) / 10000;
    }

    function modifyExtendData(
        uint256 id,
        bytes memory extendData
    ) external {
        require(msg.sender == _minter, "PExtendable1155: FORBIDDEN");

        // require(
        //     exists(id),
        //     "PExtendable1155: id not exist"
        // );

        // modify extend data
        _extendDatas[id] = extendData;

        emit Extendable1155Modify(id, extendData);
    }

    function getExtendData(uint256 id)
        external
        view
        returns (bytes memory)
    {
        require(
            exists(id),
            "PExtendable1155: id not exist"
        );

        return _extendDatas[id];
    }

}