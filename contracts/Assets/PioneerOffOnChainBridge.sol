// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (PioneerOffOnChainBridge.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../Base/PMintable20.sol";
import "../Base/PCapped20.sol";

import "../Utility/TransferHelper.sol";

contract PioneerOffOnChainBridge is
    Context,
    Pausable,
    AccessControl 
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant SERVICE_ROLE = keccak256("SERVICE_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    event Off2OnChain_PSYC(address userAddr, uint256 value);
    event On2OffChain_PSYC(address userAddr, uint256 value);
    event Off2OnChain_PIOT(address userAddr, uint256 value);
    event On2OffChain_PIOT(address userAddr, uint256 value);
       
    address public _PSYCAddr;
    address public _PIOTAddr;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(SERVICE_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PioneerOffOnChainBridge: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PioneerOffOnChainBridge: must have pauser role to unpause"
        );
        _unpause();
    }
        
    function init(
        address PSYCAddr,
        address PIOTAddr
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "PioneerOffOnChainBridge: must have manager role");

        _PSYCAddr = PSYCAddr;
        _PIOTAddr = PIOTAddr;
    }

    function off2onChain_PSYC(address userAddr, uint256 value) external whenNotPaused {
        require(hasRole(SERVICE_ROLE, _msgSender()), "PioneerOffOnChainBridge: must have service role");
        require(PMintable20(_PSYCAddr).balanceOf(address(this)) >= value, "PioneerOffOnChainBridge: insufficient PSYC");

        // TransferHelper.safeTransferFrom(_PSYCAddr, address(this), userAddr, value);
        TransferHelper.safeTransfer(_PSYCAddr, userAddr, value);

        emit Off2OnChain_PSYC(userAddr, value);
    }

    function on2offChain_PSYC(uint256 value) external whenNotPaused {
        require(PMintable20(_PSYCAddr).balanceOf(address(_msgSender())) >= value, "PioneerOffOnChainBridge: insufficient PSYC");

        TransferHelper.safeTransferFrom(_PSYCAddr, _msgSender(), address(this), value);

        emit On2OffChain_PSYC(_msgSender(), value);
    }



    function off2onChain_PIOT(address userAddr, uint256 value) external whenNotPaused {
        require(hasRole(SERVICE_ROLE, _msgSender()), "PioneerOffOnChainBridge: must have service role");
        require(PCapped20(_PIOTAddr).balanceOf(address(this)) >= value, "PioneerOffOnChainBridge: insufficient PIOT");

        // TransferHelper.safeTransferFrom(_PIOTAddr, address(this), userAddr, value);
        TransferHelper.safeTransfer(_PIOTAddr, userAddr, value);
        
        emit Off2OnChain_PIOT(userAddr, value);
    }

    function on2offChain_PIOT(uint256 value) external whenNotPaused {
        require(PCapped20(_PIOTAddr).balanceOf(address(_msgSender())) >= value, "PioneerOffOnChainBridge: insufficient PIOT");

        TransferHelper.safeTransferFrom(_PIOTAddr, _msgSender(), address(this), value);

        emit On2OffChain_PIOT(_msgSender(), value);
    }
}