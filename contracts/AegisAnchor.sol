// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AegisAnchor — per-decision proof anchoring
/// @notice Batches HMAC-chained decision-hash roots onchain. Anyone can
///         re-verify the off-chain ledger against these roots: recompute the
///         HMAC chain, recompute the batch root, compare. Cheap: one SSTORE
///         per batch of decisions at Monad's gas prices.
contract AegisAnchor {
    address public aegis; // governance kernel

    struct Commit {
        bytes32 root;      // sha256/keccak over batched decision hashes
        uint40  timestamp;
        uint32  count;     // decisions covered
    }

    mapping(uint64 => Commit) public commits; // seq => commit
    uint64 public nextSeq;
    uint256 public totalDecisionsAnchored;

    event Anchored(uint64 indexed seq, bytes32 indexed root, uint32 count);

    constructor(address _aegis) { aegis = _aegis; }

    function anchor(bytes32 root, uint32 count) external {
        require(msg.sender == aegis, "only kernel");
        uint64 seq = nextSeq++;
        commits[seq] = Commit({ root: root, timestamp: uint40(block.timestamp), count: count });
        totalDecisionsAnchored += count;
        emit Anchored(seq, root, count);
    }

    /// @notice Verifier helper: does this batch root exist onchain?
    function isAnchored(bytes32 root) external view returns (bool) {
        for (uint64 i = 0; i < nextSeq; i++) if (commits[i].root == root) return true;
        return false;
    }
}
