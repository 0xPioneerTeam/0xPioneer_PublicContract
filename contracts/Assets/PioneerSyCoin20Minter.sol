// SPDX-License-Identifier: MIT
// 0xPioneer Contracts (PioneerSyCoin20Minter.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../Base/PMintable20.sol";

contract PioneerSyCoin20Minter is 
    Context, 
    AccessControl
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant FACTORY_ADMIN_ROLE = keccak256("FACTORY_ADMIN_ROLE");

    address public _psycoin;
    
    constructor(address psycoin) {
        _psycoin = psycoin;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(FACTORY_ADMIN_ROLE, _msgSender());

        _setRoleAdmin(MINTER_ROLE, FACTORY_ADMIN_ROLE);
    }

    function mintCoin20(address toAddr, uint256 value) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "PioneerSyCoin20Minter: FORBIDDEN");

        // TO DO : risk control

        PMintable20(_psycoin).mint(toAddr, value);
    }
}