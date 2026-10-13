# DoraHacks — Arc Microgrants submission: Aegis on Arc

**Tagline:** USDC-native trust and kill-switch layer for autonomous AI trading agents.

## Description
Autonomous trading agents move money with no identity, no audit trail, and no brakes. Aegis fixes all three on-chain: AegisRegistry gives each agent a verifiable identity and capability hash, AegisAnchor anchors tamper-evident ledger batches, and AegisBreaker is a fail-closed circuit breaker. When a watcher-swarm quorum detects an anomaly, the desk halts on its own, and only a human key can resume it.

## How we use Arc
- **AegisEscrow (new for Arc):** agents pre-fund **native USDC** through Arc's built-in ERC-20 interface (`0x3600…0000`, with no wrapper). Each attestation request debits a 0.01 USDC fee to the verifier. Pay-per-verification is metered in dollars.
- **Breaker-frozen funds:** when AegisBreaker trips, every escrowed USDC balance is frozen. Withdrawals, new attestations and verifier payouts all stop until a human resumes the desk. A risk event therefore locks the money, not just the logic.
- **USDC gas:** gas, fees and escrow are all denominated in USDC, so an agent's full operating cost is predictable in dollars. That is a requirement for institutional agent desks.

## Deployment (Arc mainnet, chain 5042)
- AegisRegistry: 0x70a72b4DD75939B3798261C10E2576bcCD18cCF5
- AegisAnchor: 0xd2D02D35ADB60b9b0444979197FA35916A0500a5
- AegisBreaker: 0xe94ad2Fc23e5b69F640A50FA539EF31bbe93486D
- AegisEscrow: 0x6233f3D8e53D91Da45a756b116a057AdEB6308ea
- Live USDC flow transactions (approve → deposit → paid attestation): approve 0xf004d27f4924712677ce3da8ab0535a2750286bb729042ed713eecc3692e9823, deposit 0xe1a59463920f8b3020e620968ae1232e9c23dfe24a1a68ed76fc736bc9ff2bbe, payAttestation 0x0f83be8fe9132397750a8e174cca2e4d3bd1889a7d52d15b2ad2fe470e2decda (full list in deployment.json)

## Links
- Code: https://github.com/Cubiczan/aegis-on-arc
- Live demo: https://aegis-on-monad.vercel.app
- Demo video: https://youtu.be/cNo8BCYPl6s
- Pitch video: https://youtu.be/qLVmbQJeB-o

## What's next
- Per-agent fee tiers.
- USDC slashing of misbehaving agents' escrow by breaker quorum.
- CCTP inflows so agents on other chains can fund escrow on Arc.
