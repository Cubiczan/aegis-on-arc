# DoraHacks — Arc Microgrants submission: Aegis on Arc

**Tagline:** USDC-native trust and kill-switch layer for autonomous AI trading agents.

## Description
Autonomous trading agents move money with no identity, no audit trail, and no brakes. Aegis fixes all three on-chain: AegisRegistry gives each agent a verifiable identity and capability hash, AegisAnchor anchors tamper-evident ledger batches, and AegisBreaker is a fail-closed circuit breaker. When a watcher-swarm quorum detects an anomaly, the desk halts on its own, and only a human key can resume it.

## How we use Arc
- **AegisEscrow (new for Arc):** agents pre-fund **native USDC** through Arc's built-in ERC-20 interface (`0x3600…0000`, with no wrapper). Each attestation request debits a 0.01 USDC fee to the verifier. Pay-per-verification is metered in dollars.
- **Breaker-frozen funds:** when AegisBreaker trips, every escrowed USDC balance is frozen. Withdrawals, new attestations and verifier payouts all stop until a human resumes the desk. A risk event therefore locks the money, not just the logic.
- **USDC gas:** gas, fees and escrow are all denominated in USDC, so an agent's full operating cost is predictable in dollars. That is a requirement for institutional agent desks.

## Deployment (Arc mainnet, chain 5042)
- AegisRegistry: {{REG}}
- AegisAnchor: {{ANC}}
- AegisBreaker: {{BRK}}
- AegisEscrow: {{ESC}}
- Live USDC flow transactions (approve → deposit → paid attestation): {{TXS}}

## Links
- Code: https://github.com/Cubiczan/aegis-on-arc
- Live demo: https://aegis-on-monad.vercel.app
- Demo video: https://youtu.be/cNo8BCYPl6s
- Pitch video: https://youtu.be/qLVmbQJeB-o

## What's next
- Per-agent fee tiers.
- USDC slashing of misbehaving agents' escrow by breaker quorum.
- CCTP inflows so agents on other chains can fund escrow on Arc.
