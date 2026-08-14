# MY PERC — Release notes

## v1.1.8 (build 13) — macOS explorer tip sync (14 August 2026)

- **macOS app:** `perccent-wallet-v1.1.8-macos-setup.zip` (~19.7 MB)
  - Contains `MY PERC.app` (universal), version `1.1.8` build `13`
  - Sandbox now includes `network.client` so the wallet can fetch Helsinki `/perc/ledger`
  - Parses tip blocks that omit `treasuryEmitted` / tx `amount` (those used to abort adopt at height 94)
  - SHA-256: `95f214ad3a52e6f04fe819a034736998c15570574d0b0ac318b2b94b9a253a03`
- **Install:** unzip and open `MY PERC.app` from [Releases](https://github.com/rgsneddon/perccent-wallet/releases/tag/v1.1.8).

## v1.1.7 (build 12) — Apple platforms bump (iOS + macOS) (14 July 2026)

Product name: **MY PERC** (`perccent_wallet`).

### Highlights

- **iOS IPA:** `perccent-wallet-v1.1.7-ios-setup.ipa` (~8.3 MB)
  - Bundle ID: `perccent-wallet`
  - Team: `SFCBP95595`
  - Identity: Apple Development (Russell Sneddon)
  - SHA-256: `05cbc25eef4112516f6525b29f008259d9ebd6689d8eb40dea75a1a8e54f932d`
- **macOS app:** `perccent-wallet-v1.1.7-macos-setup.zip` (~19.7 MB)
  - Contains `MY PERC.app` (universal arm64 + x86_64), CFBundleShortVersionString `1.1.7` build `12`
  - Bundle ID: `perccent-wallet`
  - Team: `SFCBP95595` — **Developer ID Application** signed, **notarized** (ticket stapled)
  - SHA-256: `ca08120f2573805a0f17e4d05e68c31983428008fc7360f3e572a8638f61f3db`
- **version.json** top-level `1.1.7+12`; platform fields: iOS/macOS `1.1.7+12`, Windows/Android remain `1.1.6+11`.
- Windows/Android installers unchanged on **v1.1.6**.

### Install (iOS)

1. Download `perccent-wallet-v1.1.7-ios-setup.ipa` from [Releases](https://github.com/rgsneddon/perccent-wallet/releases/tag/v1.1.7) or [Downloads](https://rgsneddon.github.io/perccent-wallet/downloads/).
2. Verify SHA-256 against the `.sha256` sidecar.
3. Sideload with Apple Configurator, AltStore, or MDM; trust the developer certificate if prompted.

### Install (macOS)

1. Download `perccent-wallet-v1.1.7-macos-setup.zip` from [Releases](https://github.com/rgsneddon/perccent-wallet/releases/tag/v1.1.7) or [Downloads](https://rgsneddon.github.io/perccent-wallet/downloads/).
2. Verify SHA-256 against the `.sha256` sidecar.
3. Unzip and open `MY PERC.app` (Notarized Developer ID — Gatekeeper should allow a normal open).

---

## v1.1.6 (build 11) — Aligned platform installers + update-check fix (14 July 2026)

Product name: **MY PERC** (`perccent_wallet`).

### Highlights

- **Signed iOS IPA published:** `perccent-wallet-v1.1.6-ios-setup.ipa` (~8.3 MB)
  - Bundle ID: `perccent-wallet` (App ID on team `SFCBP95595`)
  - Team: `SFCBP95595`
  - Identity: Apple Development (Russell Sneddon)
  - SHA-256: `5953c92a0429b45fd54dab7ef1be14d80e0d5349a49d1bb9803b964576270b28`
- **macOS app published:** `perccent-wallet-v1.1.6-macos-setup.zip` (~19.7 MB)
  - Contains `MY PERC.app` (universal arm64 + x86_64)
  - Bundle ID: `perccent-wallet`
  - Team: `SFCBP95595` — **Developer ID Application** signed, **notarized** (ticket stapled)
  - SHA-256: `5742d898a27a4a79b7346215c4cc22f63d00d3417a14c6b4e7dbff094fb99597`
  - Install: unzip and open `MY PERC.app` (Gatekeeper should accept as Notarized Developer ID)
- **App ID / Bundle ID migration:** iOS + macOS rebuilt and re-published under Bundle ID `perccent-wallet` (matches App ID on team `SFCBP95595`). Previous `com.perccent.perccentWallet` binaries replaced on the same v1.1.6 tag.
- **Downloads page** lists v1.1.6 with real iOS + macOS size/SHA-256 (not placeholders).
- **Signing project settings** committed: `DEVELOPMENT_TEAM=SFCBP95595` in Xcode project + `ExportOptions.plist`.
- **Windows and Android rebuilt** on the unified **v1.1.6** tag: `perccent-wallet-v1.1.6-windows-x64-setup.exe` and `perccent-wallet-v1.1.6-android-setup.apk`.
- **Platform-specific splash update checks:** `version.json` now includes per-platform version fields; the sign-in update advisory compares only your device type (Windows, Android, or iOS), so a newer iOS-only release no longer nags Windows or Android users who are already current.

### Biometrics (current)

- Optional **Face ID / Touch ID / fingerprint** vault on **iOS and Android** after login or registration seed setup.
- Send re-auth accepts enrolled biometrics or password on both mobile platforms.

### iOS signing note

Automatic `flutter build ipa` archive failed because the Apple team has **no registered devices** for a development provisioning profile. The published IPA is a **release build** of `Runner.app` codesigned with the Apple Development certificate and packaged as a standard Payload IPA for GitHub distribution / sideload workflows. Full Xcode automatic provisioning for device install improves once a physical device UDID is registered on the team.

### Platforms

| Platform | Status |
|----------|--------|
| Windows | **v1.1.6** installer on Releases / Downloads |
| Android | **v1.1.6** APK on Releases / Downloads |
| **iOS** | **v1.1.6 signed IPA** on Releases / Downloads |
| **macOS** | **v1.1.6 app zip** on Releases / Downloads |
| Web | `flutter build web --release` from source |

### Install (iOS IPA)

1. Download `perccent-wallet-v1.1.6-ios-setup.ipa` from [Releases](https://github.com/rgsneddon/perccent-wallet/releases/tag/v1.1.6) or [Downloads](https://rgsneddon.github.io/perccent-wallet/downloads/).
2. Verify SHA-256 against the `.sha256` sidecar.
3. Sideload with Apple Configurator, AltStore, or MDM; trust the developer certificate if prompted.

### Install (macOS)

1. Download `perccent-wallet-v1.1.6-macos-setup.zip` from [Releases](https://github.com/rgsneddon/perccent-wallet/releases/tag/v1.1.6) or [Downloads](https://rgsneddon.github.io/perccent-wallet/downloads/).
2. Verify SHA-256 against the `.sha256` sidecar.
3. Unzip and open `MY PERC.app`. This build is Developer ID–signed and notarized (stapled); Gatekeeper should allow a normal open.

### Docs

- [README.md](README.md) — v1.1.6 latest + iOS IPA artifact
- [ios/SIGNING.md](ios/SIGNING.md) — team `SFCBP95595`
- [PRIVACY_POLICY.md](PRIVACY_POLICY.md) / [LICENSE](LICENSE) — multi-platform MY PERC (unchanged policy model)

---

## v1.1.5 (build 10) — iOS build support & legal/docs (13 July 2026)

Product name: **MY PERC** (`perccent_wallet`).

### Highlights

- **iOS is a supported build target** for MY PERC. The `ios/` Xcode project, CocoaPods `Podfile`, and packaging scripts produce a real simulator app (`build/ios/iphonesimulator/Runner.app`, bundle id `perccent-wallet`).
- **Build path documented** in [README.md](README.md).
- **Privacy policy** and **LICENSE** updated for MY PERC multi-platform distribution (including iOS). Biometric vault enrollment later extended to **Android and iOS** (see current README / PRIVACY_POLICY).
