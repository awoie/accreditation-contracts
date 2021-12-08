pragma solidity ^0.5.0;

import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-eth/contracts/access/Roles.sol";

contract AccreditationRoles is Initializable {
    using Roles for Roles.Role;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);
    event AccreditationMinterAdded(uint256 indexed accreditationId, address indexed account);
    event AccreditationMinterRemoved(uint256 indexed accreditationId, address indexed account);

    Roles.Role private _admins;
    mapping(uint256 => Roles.Role) private _minters;

    function initialize(address sender) public initializer {
        if (!isAdmin(sender)) {
            _addAdmin(sender);
        }
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }

    modifier onlyAccreditationMinter(uint256 accreditationId) {
        require(isAccreditationMinter(accreditationId, msg.sender));
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins.has(account);
    }

    function isAccreditationMinter(uint256 accreditationId, address account) public view returns (bool) {
        return isAdmin(account) || _minters[accreditationId].has(account);
    }

    function addAccreditationMinter(uint256 accreditationId, address account) public onlyAccreditationMinter(accreditationId) {
        _addAccreditationMinter(accreditationId, account);
    }

    function addAdmin(address account) public onlyAdmin {
        _addAdmin(account);
    }

    function renounceAccreditationMinter(uint256 accreditationId) public {
        _removeAccreditationMinter(accreditationId, msg.sender);
    }

    function renounceAdmin() public {
        _removeAdmin(msg.sender);
    }

    function removeAccreditationMinter(uint256 accreditationId, address account) public onlyAdmin {
        _removeAccreditationMinter(accreditationId, account);
    }

    function _addAccreditationMinter(uint256 accreditationId, address account) internal {
        _minters[accreditationId].add(account);
        emit AccreditationMinterAdded(accreditationId, account);
    }

    function _addAdmin(address account) internal {
        _admins.add(account);
        emit AdminAdded(account);
    }

    function _removeAccreditationMinter(uint256 accreditationId, address account) internal {
        _minters[accreditationId].remove(account);
        emit AccreditationMinterRemoved(accreditationId, account);
    }

    function _removeAdmin(address account) internal {
        _admins.remove(account);
        emit AdminRemoved(account);
    }

    // For future extensions
    uint256[50] private ______gap;
}
