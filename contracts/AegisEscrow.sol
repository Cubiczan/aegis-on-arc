// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transferFrom(address f, address t, uint256 v) external returns (bool);
    function transfer(address t, uint256 v) external returns (bool);
}
interface IBreaker { function paused() external view returns (bool); }

/// @title AegisEscrow — USDC-native pay-per-verification on Arc
/// @notice Agents pre-fund USDC (Arc native USDC ERC-20 interface, 6 decimals).
///         Each attestation request debits a fixed USDC fee to the verifier.
///         When the AegisBreaker is paused, all escrowed USDC is frozen
///         (no withdrawals, no fee payouts) until the human key resumes.
contract AegisEscrow {
    IERC20 public immutable usdc;
    IBreaker public immutable breaker;
    address public immutable verifier;
    uint256 public immutable feePerAttestation; // 6-decimal USDC units

    mapping(address => uint256) public balanceOf;
    mapping(bytes32 => address) public attestationPayer;
    uint256 public verifierEarned;

    event Deposited(address indexed agent, uint256 amount);
    event Withdrawn(address indexed agent, uint256 amount);
    event AttestationPaid(address indexed agent, bytes32 indexed attestation, uint256 fee);
    event VerifierClaimed(uint256 amount);

    modifier notFrozen() { require(!breaker.paused(), "frozen by breaker"); _; }

    constructor(address _usdc, address _breaker, address _verifier, uint256 _fee) {
        usdc = IERC20(_usdc); breaker = IBreaker(_breaker); verifier = _verifier; feePerAttestation = _fee;
    }

    function deposit(uint256 amount) external {
        require(usdc.transferFrom(msg.sender, address(this), amount), "transferFrom");
        balanceOf[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function requestAttestation(bytes32 attestation) external notFrozen {
        require(attestationPayer[attestation] == address(0), "already paid");
        require(balanceOf[msg.sender] >= feePerAttestation, "insufficient escrow");
        balanceOf[msg.sender] -= feePerAttestation;
        verifierEarned += feePerAttestation;
        attestationPayer[attestation] = msg.sender;
        emit AttestationPaid(msg.sender, attestation, feePerAttestation);
    }

    function withdraw(uint256 amount) external notFrozen {
        require(balanceOf[msg.sender] >= amount, "insufficient");
        balanceOf[msg.sender] -= amount;
        require(usdc.transfer(msg.sender, amount), "transfer");
        emit Withdrawn(msg.sender, amount);
    }

    function claimFees() external notFrozen {
        require(msg.sender == verifier, "not verifier");
        uint256 a = verifierEarned; verifierEarned = 0;
        require(usdc.transfer(verifier, a), "transfer");
        emit VerifierClaimed(a);
    }
}
