//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IGalva {
    // Logged when property owner attest to a new ownership
    event Attest(bytes32 indexed node);

    /**
      * @notice Register property
      * @dev Attest to a new proeprty ownership
      * @param node Attestor from ens
      * @param title Land title
      * @param area Approximate area
      * @param owner Attestor
      */
    function attestProperty(bytes32 node, string memory title, uint256 area, address owner) external;
    /**
      * @notice We assume a cryptographical truth
      * @dev Check if record exists(has already been consumed by the blockchain)
      * @param node Record hash
      * @return bool
      */
    function recordExists(bytes32 node) external returns (bool);
    /**
      * @notice Get property if it exists in the blockchain
      * @dev Query attested property
      * @param node Record hash
      * @return (string memory title, uint256 area)
      */
    function getProperty(bytes32 node) external returns (string memory, uint256);
    /**
      * @notice Claim ownership to property
      * @dev Return true if claimer is the owner
      * @param node Record hash
      * @param v Parity of the y co-ordinate of r
      * @param r The x co-ordinate of r
      * @param s The s value of the signature
      * @return bool
      */
    function claimOwnership(bytes32 node, uint8 v,  bytes32 r, bytes32 s) external returns(bool);
    /**
      * @notice Consumed rights
      * @dev Return consumed rights for an address
      * @param who Address
      * @return uint256
      */
    function addressRights(address who) external returns (uint256);
    /**
      * @notice Blockchain consumed rights
      * @dev Returns rights consumed by the blockchain
      * @return uint256
      */
    function consumedRights() external returns (uint256);
}
