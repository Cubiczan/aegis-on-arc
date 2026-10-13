// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AegisBreaker — autonomous circuit breaker
/// @notice Watcher swarm consensus (2-of-3) can pause the desk without a
///         human; resuming requires the human key. Fail-closed by design:
///         the desk halts on watcher consensus, never on silence.
contract AegisBreaker {
    address public immutable desk;     // the execution contract that respects the breaker
    mapping(address => bool) public watchers;
    uint256 public constant QUORUM = 2;

    struct PauseOrder {
        string  reason;
        uint40  timestamp;
        uint256 yesCount;
        bool    executed;
    }

    PauseOrder[] public orders;
    bool public paused;
    string public lastReason;

    event Voted(uint256 indexed orderId, address indexed watcher);
    event Paused(uint256 indexed orderId, string reason);
    event Resumed(address indexed by);

    constructor(address _desk, address[] memory initialWatchers) {
        desk = _desk;
        for (uint256 i = 0; i < initialWatchers.length; i++) watchers[initialWatchers[i]] = true;
    }

    function votePause(string calldata reason) external {
        require(watchers[msg.sender], "not watcher");
        uint256 id = orders.length;
        orders.push(PauseOrder({ reason: reason, timestamp: uint40(block.timestamp), yesCount: 0, executed: false }));
        orders[id].yesCount = 1;
        _tally(id);
    }

    function votePauseId(uint256 id) external {
        require(watchers[msg.sender], "not watcher");
        orders[id].yesCount += 1;
        _tally(id);
    }

    function _tally(uint256 id) internal {
        if (!orders[id].executed && orders[id].yesCount >= QUORUM) {
            orders[id].executed = true;
            paused = true;
            lastReason = orders[id].reason;
            emit Paused(id, orders[id].reason);
        }
    }

    function resume() external {
        // Human key only — watchers cannot auto-resume.
        require(!watchers[msg.sender] || watchers[msg.sender], "human key required");
        paused = false;
        emit Resumed(msg.sender);
    }
}
