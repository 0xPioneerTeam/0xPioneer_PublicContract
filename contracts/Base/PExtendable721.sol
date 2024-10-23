// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (PExtendable721.sol)

pragma solidity ^0.8.0;

import "../Interface/IERC2981Royalties.sol";

import "../Utility/ResetableCounters.sol";

import "./PBase721.sol";

abstract contract PExtendable721 is 
    IERC2981Royalties,
    PBase721
{
    using ResetableCounters for ResetableCounters.Counter;

    event PExtendable721Mint(address indexed toAddr, uint256 indexed tokenId, bytes fixedData);
    event PExtendData(string dataName);
    event PExtendDataModified(uint256 indexed tokenId, string dataName, bytes newData);
    
    ResetableCounters.Counter internal _tokenIdTracker;

    address public _minter;
    address public _owner;
    address public _codec;

    // erc2981 royalty fee, /10000
    uint256 public _royalties;
    address public _royalFeeAddr;
    string internal _baseTokenURI;
    
    mapping(uint256 => bytes) internal _fixedData; // token id => fixed nft data
    mapping(uint256 => mapping(string=>bytes)) internal _writeableData; // token id => data name => writeable data
    mapping(string=>bool) public _writeableDataNames; // writeable data name => is exist
    string[] _writeableDataNameArray;

    // proxy implementation do not use constructor, use initialize instead
    constructor() payable {}
    
    function isOwner(address addr) public view returns(bool) {
        return _owner == addr;
    }

    function changeOwner(address newOwner) external {
        require(msg.sender == _owner, "PExtendable721: FORBIDDEN");

        _owner = newOwner;
    }

    function __chain_initialize_PExtendable721(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address codec,
        uint256 royalties,
        uint256 idStart
    ) internal onlyInitializing {

        _royalFeeAddr = _owner;
        _royalties = royalties;

        _codec = codec;

        _baseTokenURI = baseURI;
        _tokenIdTracker.reset(idStart);
        __chain_initialize_PBase721(name, symbol);
    }

    function _mintWithData(address to, bytes memory fixedData) internal returns(uint256) {
        uint256 curID = _tokenIdTracker.current();

        _mint(to, curID);

        // Save token datas
        _fixedData[curID] = fixedData;

        emit PExtendable721Mint(to, curID, fixedData);

        // increase token id
        _tokenIdTracker.increment();

        return curID;
    }

    function _mintFixedIdWithData(address to, uint256 tokenId, bytes memory fixedData) internal returns(uint256) {
        require(!_exists(tokenId), "PExtendable721: token already exist");

        _mint(to, tokenId);

        // Save token datas
        _fixedData[tokenId] = fixedData;

        emit PExtendable721Mint(to, tokenId, fixedData);

        return tokenId;
    }

    function getFixedData(uint256 tokenId) external view returns(bytes memory data){
        require(_exists(tokenId), "PExtendable721: token not exist");

        data = _fixedData[tokenId];
    }

    function extendData(string memory dataName) external {
        require(msg.sender == _owner, "PExtendable721: FORBIDDEN");

        _writeableDataNames[dataName] = true;
        _writeableDataNameArray.push(dataName);

        emit PExtendData(dataName);
    }

    function modifyWriteableData(uint256 tokenId, string memory dataName, bytes memory data) external {
        require(msg.sender == _minter, "PExtendable721: FORBIDDEN");
        require(_writeableDataNames[dataName], "PExtendable721: data name not exist");

        _writeableData[tokenId][dataName] = data;

        emit PExtendDataModified(tokenId, dataName, data);
    }

    function getWriteabledData(uint256 tokenId, string memory dataName) external view returns (bytes memory data) {
        require(_exists(tokenId), "PExtendable721: token not exist");
        require(_writeableDataNames[dataName], "PExtendable721: data name not exist");

        data = _writeableData[tokenId][dataName];
    }

    // set royalties
    function setRoyalties(uint256 royalties, address receiver) external {
        require(msg.sender == _owner, "PExtendable721: FORBIDDEN");
        _royalties = royalties;
        _royalFeeAddr = receiver;
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
    
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC2981Royalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function updateURI(string calldata baseTokenURI) public virtual {
        require((msg.sender == _owner), "PExtendable721: FORBIDDEN");
        _baseTokenURI = baseTokenURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (to == address(0)) {
            // delete token extend datas;
            string[] memory wnameArray = _writeableDataNameArray;
            mapping(string=>bytes) storage wdatas = _writeableData[tokenId];
            for(uint i = 0; i< wnameArray.length; ++i){
                delete wdatas[wnameArray[i]];
            }

            // delete token datas
            delete _fixedData[tokenId];
        }
    }
}