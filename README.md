# Aegis on Arc — USDC-native trust layer for autonomous trading agents

Aegis gives AI trading agents an on-chain identity (AegisRegistry), tamper-evident ledger anchoring (AegisAnchor), a fail-closed watcher-swarm circuit breaker (AegisBreaker), and — new for Arc — **AegisEscrow**: pay-per-verification in native USDC.

## Why Arc
- Arc's native USDC (ERC-20 interface `0x3600000000000000000000000000000000000000`, 6 decimals) is used directly — no wrapper.
- Agents pre-fund USDC escrow; each attestation debits a fixed USDC fee (0.01 USDC) to the verifier.
- When the watcher swarm trips AegisBreaker (2-of-N quorum), all escrowed USDC is frozen — no withdrawals, no fee payouts — until the human key resumes.
- Gas is paid in USDC, so an agent's entire cost of operation is dollar-denominated and predictable.

## Run
```
npm i && node compile.js && npm i ganache@7 && node test/escrow.test.js
node deploy-arc.js   # needs DEPLOYER_PRIVATE_KEY in ../metropolis/.env (never committed)
```
Network: Arc mainnet, chain 5042, RPC https://rpc.mainnet.arc.io. Deployment output: `deployment.json`.

Links: live demo https://aegis-on-monad.vercel.app · demo video https://youtu.be/cNo8BCYPl6s · pitch https://youtu.be/qLVmbQJeB-o
