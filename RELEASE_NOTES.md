# MY PERC — Release notes

## v1.1.6 (build 11) — Signed iOS IPA (14 July 2026)

Product name: **MY PERC** (`perccent_wallet`).

### Highlights

- **Signed iOS IPA published:** `perccent-wallet-v1.1.6-ios-setup.ipa` (~8.3 MB)
  - Bundle ID: `com.perccent.perccentWallet`
  - Team: `SFCBP95595`
  - Identity: Apple Development (Russell Sneddon)
  - SHA-256: `1844aa2923a71ae51b7564ca978820c31537834b3789c144c0fa93b23dc241f5`
- **Downloads page** lists v1.1.6 as latest with a real iOS size + SHA-256 (not a placeholder).
- **Signing project settings** committed: `DEVELOPMENT_TEAM=SFCBP95595` in Xcode project + `ExportOptions.plist`.
- Windows and Android installers were **not** rebuilt this cycle; downloads still link the verified **v1.1.5** Windows/Android packages so links do not 404.

### iOS signing note

Automatic `flutter build ipa` archive failed because the Apple team has **no registered devices** for a development provisioning profile. The published IPA is a **release build** of `Runner.app` codesigned with the Apple Development certificate and packaged as a standard Payload IPA for GitHub distribution / sideload workflows. Full Xcode automatic provisioning for device install improves once a physical device UDID is registered on the team.

### Platforms

| Platform | Status |
|----------|--------|
| Windows | v1.1.5 installer on Releases / Downloads |
| Android | v1.1.5 APK on Releases / Downloads |
| **iOS** | **v1.1.6 signed IPA** on Releases / Downloads |
| Web | `flutter build web --release` from source |

### Install (iOS IPA)

1. Download `perccent-wallet-v1.1.6-ios-setup.ipa` from [Releases](https://github.com/rgsneddon/perccent-wallet/releases/tag/v1.1.6) or [Downloads](https://rgsneddon.github.io/perccent-wallet/downloads/).
2. Verify SHA-256 against the `.sha256` sidecar.
3. Sideload with Apple Configurator, AltStore, or MDM; trust the developer certificate if prompted.

### Docs

- [README.md](README.md) — v1.1.6 latest + iOS IPA artifact
- [ios/SIGNING.md](ios/SIGNING.md) — team `SFCBP95595`
- [PRIVACY_POLICY.md](PRIVACY_POLICY.md) / [LICENSE](LICENSE) — multi-platform MY PERC (unchanged policy model)

---

## v1.1.5 (build 10) — iOS build support & legal/docs (13 July 2026)

Product name: **MY PERC** (`perccent_wallet`).

### Highlights

- **iOS is a supported build target** for MY PERC. The `ios/` Xcode project, CocoaPods `Podfile`, and packaging scripts produce a real simulator app (`build/ios/iphonesimulator/Runner.app`, bundle id `com.perccent.perccentWallet`).
- **Build path documented** in [README.md](README.md).
- **Privacy policy** and **LICENSE** updated for MY PERC multi-platform distribution (including iOS). Biometric vault enrollment remains **Android-only**.
