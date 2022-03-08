// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

/**
 * @dev A contract to allow users to claim tokens via a 'merkle airdrop'.
 */
contract MerkleAirdrop is Ownable {
    using BitMaps for BitMaps.BitMap;

    address public immutable sender;
    IERC20 public immutable token;
    bytes32 public immutable merkleRoot;
    BitMaps.BitMap private claimed;

    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address account, uint256 amount);

    /**
     * @dev Constructor.
     * @param _sender The account to send airdrop tokens from.
     * @param _token The token contract to send tokens with.
     */
    constructor(
        address _sender,
        IERC20 _token,
        bytes32 _merkleRoot
    ) {
        sender = _sender;
        token = _token;
        merkleRoot = _merkleRoot;
    }

    /**
     * @dev Claims airdropped tokens.
     * @param index  The index of leaf
     * @param recipient The account being claimed for.
     * @param amount The amount of the claim being made.
     * @param merkleProof A merkle proof proving the claim is valid.
     */
    function claim(
        uint256 index,
        address recipient,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        require(!isClaimed(index), "MerkleAirdrop: Tokens already claimed.");
        bytes32 leaf = keccak256(abi.encodePacked(index, recipient, amount));
        require(
            MerkleProof.verify(merkleProof, merkleRoot, leaf),
            "MerkleAirdrop: Valid proof required."
        );

        claimed.set(index);

        token.transferFrom(sender, recipient, amount);

        emit Claimed(index, recipient, amount);
    }

    /**
     * @dev Returns true if the claim at the given index in the merkle tree has already been made.
     * @param index The index into the merkle tree.
     */
    function isClaimed(uint256 index) public view returns (bool) {
        return claimed.get(index);
    }
}
