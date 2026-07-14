# MY PERC (Perccent Wallet) — Privacy Policy

**Effective date:** 8 July 2026  
**Last updated:** 14 July 2026 (v1.1.6+ biometric vault on Android and iOS — Face ID / Touch ID / fingerprint opt-in; signed iOS IPA; randomly assigned PERC addresses; multi-device seed/backup sync; send re-authentication; inbound credits at one main-chain confirmation; Android pull-to-refresh; hold-to-reveal login password)
**Applies to:** the standalone **MY PERC** / Perccent Wallet application on **Windows, Android, iOS, web, and other Flutter targets**, and the optional self-hosted `perc_chain` internet seed node in this repository.

## Summary

MY PERC is designed to minimise data collection. Your wallet keys, passwords, encrypted backups, and ledger state stay on your device unless you explicitly send transactions or sync with the public Perccent network. We do not operate a central account service for this standalone app.

On **Android and iOS**, you may optionally enable **biometric sign-in** after logging in or completing new-registration seed setup. If you opt in, your username and password are stored **only on your device** in OS-backed secure storage (Android encrypted shared preferences / iOS Keychain) and unlocked via the device biometric prompt (fingerprint, Face ID, or Touch ID). Biometric data and plaintext passwords are **not** sent to Evolve, seed servers, or third parties. You can decline and keep manual login. Web and desktop builds do not offer biometric vault enrollment.

Each independent wallet registration receives a **randomly assigned PERC address** — not derived from your username or password. Wallets restored from the same seed phrase or encrypted backup file share the same address across devices, and balances and transaction history merge when either clone sends or receives PERC.

Before any **outbound PERC send**, the app requires **password re-authentication** or, when enrolled on Android or iOS, a successful **biometric unlock**. Receive, staking, and backup flows do not use this send gate.

## What the wallet stores locally

On your phone (including **iOS** and Android), desktop, or browser storage, the app may persist:

- **Account credentials** — username, salted password hash, and session state (not your plaintext password after login).
- **Optional mobile biometric vault (Android and iOS)** — if you opt in after signing in, your username and password in OS-backed secure storage (`flutter_secure_storage`: encrypted shared preferences on Android; Keychain with first-unlock accessibility on iOS) for biometric unlock via `local_auth` (fingerprint / Face ID / Touch ID). This is never uploaded to servers.
- **Ledger data** — balances, transaction history, scenario blocks, stash, and staking state for your Perccent accounts (file-backed on mobile/desktop via `path_provider` where applicable).
- **Recovery material** — optional 12-word BIP-39 mnemonic and encrypted `.percbackup` files you create.
- **Locale preferences** — language and region selection.
- **Network cache** — last-known seed height, peer rendezvous hints, and sync checkpoints from `assets/config/perc_network.json` and live probes.
- **Camera (mobile)** — used only when you open the PERC QR scanner; permission is requested at that time (iOS `NSCameraUsageDescription` / Android runtime permission).

This data is stored using platform-specific secure storage where available. You are responsible for backup passphrases and seed phrases.

## Send re-authentication

When you confirm an outbound PERC transfer, MY PERC asks for your wallet password or, on Android or iOS with enrolled biometrics, a device biometric prompt that unlocks your on-device stored credentials. Cancel or failure aborts the send with no debit. This applies **only** to sends — not to receive, staking, sync, or other wallet actions.

## What the wallet sends over the network

When you use send/receive, staking, or seed sync, the wallet communicates with:

- **Public internet seed nodes** (default rendezvous: `https://evolve-perc-internet.onrender.com`, configurable in `assets/config/perc_network.json`).
- **Other Perccent peers** via the mesh rendezvous protocol for inbound transfer delivery and block propagation.
- **Public IP lookup services** (e.g. `api.ipify.org`, `ifconfig.me`) to advertise your node's public endpoint when you run local peer features.
- **Optional update checks** — the splash screen may request version metadata from configured update endpoints (no wallet secrets are sent). The MY PERC **iOS IPA** is distributed via the **perccent-wallet** GitHub Releases / downloads page (not as an Evolve Chronoflux platform installer).

Transactions and ledger exports use pseudonymous Perccent addresses and hashed account identifiers. Scenario labels and usernames are stripped from public ledger exports per chain privacy rules.

Biometric sign-in and send re-authentication do **not** transmit your fingerprint, face data, biometric templates, or stored plaintext password to network services.

## Self-hosted seed nodes

If you deploy `perc_chain` on your own VM (see `render.yaml`):

- **You** are the data controller for logs, disk snapshots, and environment variables on that host.
- The seed stores a **public ledger replica** for chain `evolve-chronoflux-principia-chain-1` and serves rendezvous for wallets that point to your URL.
- Seed nodes do not receive your wallet password or mnemonic. They may see network traffic metadata (IP addresses, request timestamps) in server logs.
- Deployed seeds join the **same public network** as existing seeds; they do not replace the official Evolve seed unless wallets are reconfigured to use only your URL.

## What we do not collect

The standalone wallet repository authors do **not**:

- Operate analytics or advertising SDKs in this build.
- Upload your mnemonic, backup passphrase, or plaintext password to Evolve servers.
- Receive or store biometric templates from your device.
- Run the optional Evolve Mishi moderator bridge (disabled in this standalone build).

## Third-party services

Your use of Render, other cloud providers, Flutter dependencies, or public seed URLs is subject to those parties' policies. Review their terms when deploying or syncing. Mobile biometric unlock uses your device's platform biometric API (`local_auth`); Google/Android and Apple process biometric verification under their own device policies. MY PERC never receives or stores biometric templates — only an on-device encrypted username/password vault gated by a successful platform biometric prompt.

## Children's privacy

The Software is not directed at children under 13. We do not knowingly collect personal information from children.

## Changes

Material changes to this policy will be noted in the repository and the "Last updated" line above. Continued use after updates constitutes acceptance of the revised policy.

## Contact

Privacy questions: **russell.gray.sneddon@gmail.com**

## Your rights

Depending on your jurisdiction you may have rights to access, correct, or delete personal data. Because wallet state is primarily local and pseudonymous on-chain, exercise those rights by managing backups on your device, declining biometric enrollment, clearing app data to remove opt-in credentials, and choosing which seed nodes you trust.