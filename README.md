# MY PERC (Perccent Wallet)

**MY PERC** is the standalone Flutter wallet for the Perccent (PERC) ledger on chain `evolve-chronoflux-principia-chain-1`. Use it without the Evolve analysis app — same dark UI styling and full wallet feature set inherited from [Evolve](https://github.com/rgsneddon/evolve).

Package name: `perccent_wallet` · Bundle ID (iOS): `com.perccent.perccentWallet`

**Latest release:** v1.1.6 (build 11) — [Downloads](https://rgsneddon.github.io/perccent-wallet/downloads/) · [Releases](https://github.com/rgsneddon/perccent-wallet/releases) · [Release notes](RELEASE_NOTES.md)

| Platform | Artifact |
|----------|----------|
| **Windows** | `perccent-wallet-v1.1.5-windows-x64-setup.exe` (last Windows build) |
| **Android** | `perccent-wallet-v1.1.5-android-setup.apk` (last Android build) |
| **iOS** | `perccent-wallet-v1.1.6-ios-setup.ipa` (Apple Development–signed, team `SFCBP95595`) |

Download installers from [Downloads](https://rgsneddon.github.io/perccent-wallet/downloads/) or **Releases**. Verify the attached `.sha256` checksum before installing.

## Features

- **Send / receive** PERC with QR codes, relay delivery, and switch commitments
- **Staking** and treasury rewards
- **Registration & login** with optional 12-word seed recovery, hold-to-reveal password (eye icon), and optional **Android biometric sign-in** after login or registration seed setup (user opt-in; iOS Face ID vault enrollment is not enabled in this release)
- **Random PERC addresses** — each independent registration gets a randomly assigned address, not derived from username or password
- **Multi-device wallet sync** — wallets restored from the same seed or backup share address, balance, and transaction history across devices
- **Send re-authentication** — outbound PERC sends require password or enrolled Android biometric confirmation; receive, staking, and sync are unchanged
- **Encrypted backup** (`.percbackup`) and restore
- **Blockchain explorer** with Chronoflux shard graphs
- **Security** tab for backup export and file restore
- **Credit** tab with governance context and creator attribution
- **Multi-language** UI (EN, ES, FR, DE, PT, AR, ZH, HI, JA)
- **Desktop & mobile** builds — Windows, Android, **iOS**, web, and other Flutter targets

### Transfer policy

| Mechanism | Purpose |
|-----------|---------|
| **Inbound credits** | Receiver balance updates after **one main-chain confirmation**; pending inbound transfers stay visible until confirmed |
| **Android wallet refresh** | Pull down on wallet screens to trigger an immediate inbound sync |
| **Send fee** | **1 cent** burned on every outbound transfer (permanently removed from circulation) |
| **Peer mesh gossip** | Wallets sync taller chains and pending transfers without a central custodian |

## Quick start (wallet app)

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) 3.2+ (stable channel)
- For Android: SDK 21+
- For **iOS**: macOS with Xcode 15+ (or current stable), CocoaPods, and an iOS Simulator runtime (or a development team for device/IPA builds)
- For desktop: platform build tools per Flutter docs

### Run locally

```bash
git clone https://github.com/rgsneddon/perccent-wallet.git
cd perccent-wallet
flutter pub get
flutter run
```

### iOS (MY PERC)

```bash
# Simulator (no Apple Developer certificate required)
flutter pub get
cd ios && pod install && cd ..
flutter run -d ios
# or compile only:
flutter build ios --simulator --debug
# Product: build/ios/iphonesimulator/Runner.app

# Device / signed IPA (requires DEVELOPMENT_TEAM + signing identity)
export DEVELOPMENT_TEAM=SFCBP95595   # see ios/SIGNING.md
# Xcode automatic archive needs a registered device for development profiles.
# Release IPA may also be produced via: flutter build ios --release --no-codesign
# then codesign + zip Payload (see RELEASE_NOTES.md / packaging scripts).
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
# Or package with checksums (macOS host with PowerShell):
#   pwsh ./scripts/build_ios_installer.ps1
```

Bundle ID: `com.perccent.perccentWallet`. Camera and Face ID usage strings are set in `ios/Runner/Info.plist` for QR scan and future biometric unlock; **password login works on iOS today**. Optional biometric vault enrollment remains **Android-only** in this release.

### Build release

```bash
# Android APK
flutter build apk --release

# Windows
flutter build windows --release

# iOS simulator app
flutter build ios --simulator --debug

# iOS release IPA (signed — see ios/SIGNING.md)
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

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

## Security / Safe use

MY PERC (Perccent Wallet) release installers are **checked regularly for safe use** before publish:

- **Malware scan** — `perccent-wallet-v*-windows-x64-setup.exe`, `perccent-wallet-v*-android-setup.apk`, and signed `perccent-wallet-v*-ios-setup.ipa` (when produced) under `build/downloads/v<version>/` are scanned with Windows Defender (when available) plus APK/PE/IPA integrity checks (expected Android package id `com.perccent.perccent_wallet`; iOS bundle id `com.perccent.perccentWallet`).
- **Dependency audit** — `flutter pub audit` and `npm audit --audit-level=high` in `perc_chain/` run before each release; documented exceptions live in [SECURITY.md](SECURITY.md).
- **Integrity** — SHA-256 and SHA-512 checksum sidecars ship with every release asset on [GitHub Releases](https://github.com/rgsneddon/perccent-wallet/releases). Verify the `.sha256` file **before installing**.

**Limitation:** Scans and checksums improve confidence but **do not guarantee** absolute safety. Verify downloads from official URLs, compare checksums, and keep device antivirus enabled.

**Regular command:** **run security audit** — `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_security_audit.ps1` (workspace wrapper: `..\run_security_audit.ps1` audits Evolve + Perccent).

Pipeline scripts: `scripts/run_security_audit.ps1`, `scripts/scan_release_artifacts.ps1`, `scripts/audit_dependencies.ps1`, wired into `build_installers.ps1` and `publish_github_release.ps1`. Post-work manual QA: [MANUAL_TESTS.md](MANUAL_TESTS.md).

---

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
| `lib/main.dart` | Standalone MY PERC app entry |
| `lib/screens/wallet_shell_screen.dart` | Wallet / Security / Credit tabs |
| `ios/` | iOS Xcode project, Podfile, signing notes (`SIGNING.md`) |
| `perc_chain/` | Internet seed node (Node.js) |
| `render.yaml` | Render blueprint for self-hosted seed |
| `RELEASE_NOTES.md` | GitHub-oriented release notes |
| `PRIVACY_POLICY.md` | Data handling for wallet + optional seed |
| `LICENSE` | Proprietary / dual license (all platforms including iOS) |

## Relationship to Evolve

This repo is extracted from the Perccent module in [rgsneddon/evolve](https://github.com/rgsneddon/evolve). The full Evolve app adds Chronoflux analysis, FCG voting, and Grok construal. Wallet logic is kept aligned with Evolve; standalone-specific stubs disable Evolve-only integrations (Mishi bridge, analysis shell).

## License

See [LICENSE](LICENSE). Personal non-commercial use is permitted under the proprietary grant; commercial use requires a separate agreement.

**Contact:** russell.gray.sneddon@gmail.com

## Privacy

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md).