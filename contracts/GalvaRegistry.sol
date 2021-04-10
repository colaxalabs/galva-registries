//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./Galva.sol";

contract GalvaRegistry is IGalva {
    // Data model
    struct Record {
        string title;
        uint256 area;
        address owner;
    }

    // State
    mapping(bytes32 => Record) private records;
    mapping(bytes32 => bool) private nonces;
    mapping(address => uint256) private rights;
    uint256 private tokenizedRights;

    // Modifiers
    modifier authorised(bytes32 node) {
        address owner = records[node].owner;
        require(owner == msg.sender, "restricted action");
        _;
    }

    constructor() {}

    /**
      * @notice Register property
      * @dev Attest to a new proeprty ownership
      * @param node Attestor from ens
      * @param title Land title
      * @param area Approximate area
      * @param owner Attestor
      */
    function attestProperty(
        bytes32 node,
        string memory title,
        uint256 area,
        address owner
    ) external virtual override {
        // Check if node has already been consumed by the blockchain
        require(nonces[node] != true, "already consumed by the blockchain");
        records[node] = Record({
            title: title,
            area: area,
            owner: owner
        });
        tokenizedRights += area; // blockchain consumed rights
        rights[owner] += area; // address consumed rights
        emit Attest(node);
    }

    /**
      * @notice We assume a cryptographical truth
      * @dev Check if record exists(has already been consumed by the blockchain)
      * @param node Record hash
      * @return bool
      */
    function recordExists(bytes32 node) external virtual override returns (bool) {
        return nonces[node] != false;
    }

    /**
      * @notice Get property if it exists in the blockchain
      * @dev Query attested property
      * @param node Record hash
      * @return (string memory title, uint256 area)
      */
    function getProperty(
        bytes32 node
    ) external virtual override authorised(node) returns(string memory, uint256) {
        require(nonces[node] == true, "not found");
        Record storage _record = records[node];
        return (_record.title, _record.area);
    }

    /**
      * @notice Claim ownership to property
      * @dev Return true if claimer is the owner
      * @param node Record hash
      * @param v Parity of the y co-ordinate of r
      * @param r The x co-ordinate of r
      * @param s The s value of the signature
      * @return bool
      */
    function claimOwnership(bytes32 node, uint8 v, bytes32 r, bytes32 s) external virtual override returns (bool) {
        require(nonces[node] == true, "not found");
        bytes32 message = recreateMessage(node, records[node].title, records[node].area);
        address claimer = ecrecover(message, v, r, s);
        return records[node].owner == claimer;
    }

    /**
      * @notice Consumed rights
      * @dev Return consumed rights for an address
      * @param who Address
      * @return uint256
      */
    function addressRights(address who) external virtual override returns (uint256) {
        return rights[who];
    }

    /**
      * @notice Blockchain consumed rights
      * @dev Returns rights consumed by the blockchain
      * @return uint256
      */
    function consumedRights() external virtual override returns (uint256) {
        return tokenizedRights;
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        // replay eth_sign mechanism
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function recreateMessage(bytes32 node, string memory title, uint256 area) internal pure returns (bytes32) {
        // encode parameters
        bytes32 payload = keccak256(abi.encode(node, title, area));
        // reconstruct eth_sign mechanism
        bytes32 message = prefixed(payload);
        return message;
    }
}
