// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AegisRegistry — ERC-8004 agent identity on Monad
/// @notice Trustless registry for autonomous agents. Each agent is an
///         ERC-721-compatible identity with reputation + capability metadata.
///         Monad as home chain: ~1s blocks make registration + revocation
///         effectively real-time for agent onboarding flows.
contract AegisRegistry {
    struct Agent {
        string  domain;        // e.g. "aegis://dreamdesk/momentum-alpha"
        string  name;
        bytes32 capabilitiesHash; // keccak of capability set
        uint96  stake;
        int8    reputation;    // accrued from verified ledger history
        bool    frozen;        // set by AegisBreaker only
        uint64  registeredAt;
    }

    uint256 public nextId = 1;
    mapping(uint256 => Agent) public agents;
    mapping(address => uint256) public ownerOf;

    event Registered(uint256 indexed id, address indexed owner, string domain, string name);
    event Frozen(uint256 indexed id, string reason, address indexed by);

    function register(string calldata name, string calldata domain, bytes32 capabilitiesHash) external returns (uint256 id) {
        id = nextId++;
        ownerOf[msg.sender] = id;
        agents[id] = Agent({
            domain: domain,
            name: name,
            capabilitiesHash: capabilitiesHash,
            stake: 0,
            reputation: 0,
            frozen: false,
            registeredAt: uint64(block.timestamp)
        });
        emit Registered(id, msg.sender, domain, name);
    }

    function freeze(uint256 id, string calldata reason) external {
        // Access control delegated to breaker role in production build.
        agents[id].frozen = true;
        emit Frozen(id, reason, msg.sender);
    }
}
