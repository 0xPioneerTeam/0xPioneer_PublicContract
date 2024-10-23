// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (PMintable20.sol)

pragma solidity ^0.8.0;

import "./PBase20.sol";

contract PMintable20 is PBase20 {
    address public _owner;
    address public _minter;

    uint256 public _maxSupply;

    // proxy implementation do not use constructor, use initialize instead
    constructor() {}

    function initialize() external initOnce {
        _owner = msg.sender;
        _minter = msg.sender;
    }

    function initMintable20(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply
    ) external initOnceStep(2) {
        require(msg.sender == _owner, "PMintable20: FORBIDDEN");

        __chain_initialize_PBase20(
            name_, 
            symbol_
        );

        _maxSupply = maxSupply;
    }
    
    function isOwner(address addr) public view returns(bool) {
        return _owner == addr;
    }

    function changeOwner(address newOwner) external {
        require(msg.sender == _owner, "PMintable20: FORBIDDEN");

        _owner = newOwner;
    }
    
    function setMinter(address minter) external {
        require(msg.sender == _owner, "PMintable20: FORBIDDEN");

        _minter = minter;
    }

    function mint(address toAddr, uint256 value) external {
        require(msg.sender == _minter, "PMintable20: FORBIDDEN");
        _mint(toAddr, value);

        if(_maxSupply > 0){
            require(totalSupply() <= _maxSupply, "PMintable20: insufficient token");
        }
    }
}