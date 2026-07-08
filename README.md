# Perccent Wallet (standalone)

A **standalone** Flutter wallet for the Perccent (PERC) ledger on chain `evolve-chronoflux-principia-chain-1`. Use it without the Evolve analysis app — same dark UI styling and full wallet feature set inherited from [Evolve](https://github.com/rgsneddon/evolve).

## Features

- **Send / receive** PERC with QR codes, relay delivery, and switch commitments
- **Staking** and treasury rewards
- **Registration & login** with optional 12-word seed recovery
- **Encrypted backup** (`.percbackup`) and restore
- **Blockchain explorer** with Chronoflux shard graphs
- **Security** tab for backup export and file restore
- **Credit** tab with governance context and creator attribution
- **Multi-language** UI (EN, ES, FR, DE, PT, AR, ZH, HI, JA)
- **Desktop & mobile** builds (Windows window chrome via `window_manager`)

## Quick start (wallet app)

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) 3.2+ (stable channel)
- For Android: SDK 21+; for desktop: platform build tools per Flutter docs

### Run locally

```bash
git clone https://github.com/rgsneddon/perccent-wallet.git
cd perccent-wallet
flutter pub get
flutter run
```

### Build release

```bash
# Android APK
flutter build apk --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

### Network configuration

Default rendezvous and seed settings live in `assets/config/perc_network.json`:

```json
{
  "rendezvousUrl": "https://evolve-perc-internet.onrender.com",
  "seedUsername": "evolve_seed_node",
  "networkGenesisRevision": 2
}
```

Point `rendezvousUrl` at **your** self-hosted seed (see below) or keep the public Evolve seed. Additional seeds on the same chain id participate in peer sync — they do not replace one another unless wallets are configured to use only your URL.

## Self-hosted internet seed node

The `perc_chain/` package is the Node.js internet seed + rendezvous server. Deploy it on any public VM (Render, Fly.io, VPS) **alongside** existing seeds.

### Render (one-click blueprint)

1. Fork or clone this repo.
2. Open [Render](https://render.com) → **New** → **Blueprint** → connect this repository.
3. Use the included `render.yaml` (service name `perccent-wallet-seed`, `rootDir: perc_chain`).
4. Set `PERC_TREASURY_ADMIN_USER` to your Perccent treasury admin username.
5. `PERC_SEED_USERNAME` is auto-generated; note it for wallet `seedUsername` if you want wallets to prefer your node.

Health check: `GET /health` → `{ "ok": true, "service": "perc-internet-node", "ledgerReady": true }`.

### Manual / VPS

```bash
cd perc_chain
npm install
export PORT=9478
export PERC_CHAIN_GENESIS_REVISION=2
export PERC_SEED_USERNAME=my_community_seed
export PERC_TREASURY_ADMIN_USER=your_admin_user
export PERC_DATA_DIR=./data
export PERC_UPSTREAM_RENDEZVOUS_URL=https://evolve-perc-internet.onrender.com
npm run start:internet
```

`PERC_UPSTREAM_RENDEZVOUS_URL` (defaults to `rendezvousUrl` in `assets/config/perc_network.json`) lets a localhost seed merge remote peers into its local `/perc/rendezvous/peers` list while `PERC_PUBLIC_ENDPOINT` stays on your VM URL.

Persist `PERC_DATA_DIR` on disk so the ledger survives restarts.

### Verify seed

```bash
cd perc_chain
npm test                    # 76 unit tests
curl -s https://YOUR-HOST/health
curl -s https://YOUR-HOST/perc/status
curl -s "https://YOUR-HOST/perc/rendezvous/peers?chainId=evolve-chronoflux-principia-chain-1"
```

A freshly deployed seed may report `peers: 0` until wallets or other seeds register; public seeds on the same chain id appear in the peers list alongside one another.

Point the wallet at your seed by editing `assets/config/perc_network.json` before building, or override rendezvous in your deployment pipeline.

## Tests

```bash
# Wallet (Dart)
flutter test test/perc_ledger_test.dart test/perc_chain_tip_test.dart

# Full wallet suite
flutter test

# Seed node (Node)
cd perc_chain && npm test
```

## Repository layout

| Path | Purpose |
|------|---------|
| `lib/perc/` | Wallet core (ledger, network, UI screens) |
| `lib/wallet_core/` | Shared types, Chronoflux micro-engine, locale — no Evolve app shell |
| `lib/main.dart` | Standalone app entry |
| `lib/screens/wallet_shell_screen.dart` | Wallet / Security / Credit tabs |
| `perc_chain/` | Internet seed node (Node.js) |
| `render.yaml` | Render blueprint for self-hosted seed |
| `PRIVACY_POLICY.md` | Data handling for wallet + optional seed |
| `LICENSE` | Proprietary / dual license |

## Relationship to Evolve

This repo is extracted from the Perccent module in [rgsneddon/evolve](https://github.com/rgsneddon/evolve). The full Evolve app adds Chronoflux analysis, FCG voting, and Grok construal. Wallet logic is kept aligned with Evolve; standalone-specific stubs disable Evolve-only integrations (Mishi bridge, analysis shell).

## License

See [LICENSE](LICENSE). Personal non-commercial use is permitted under the proprietary grant; commercial use requires a separate agreement.

**Contact:** russell.gray.sneddon@gmail.com

## Privacy

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md).