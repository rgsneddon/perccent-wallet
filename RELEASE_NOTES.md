# MY PERC — Release notes

## v1.1.5 (build 10) — iOS build support & legal/docs (13 July 2026)

Product name: **MY PERC** (`perccent_wallet`).

### Highlights

- **iOS is a supported build target** for MY PERC. The `ios/` Xcode project, CocoaPods `Podfile`, and packaging scripts produce a real simulator app (`build/ios/iphonesimulator/Runner.app`, bundle id `com.perccent.perccentWallet`).
- **Build path documented** in [README.md](README.md): simulator via `flutter build ios --simulator --debug` / `flutter run -d ios`; signed device IPA via `flutter build ipa` and `ios/SIGNING.md` when an Apple Developer team is configured.
- **Downloads page** lists Windows, Android, and iOS. Signed `perccent-wallet-v1.1.5-ios-setup.ipa` is the planned GitHub Release artifact name once codesigning identities are available; until then, build MY PERC for iOS from this repository on macOS.
- **Privacy policy** and **LICENSE** updated for MY PERC multi-platform distribution (including iOS). Biometric vault enrollment remains **Android-only** in this release — docs no longer imply Face ID wallet unlock on iOS.

### Platforms

| Platform | Status |
|----------|--------|
| Windows | Installer on [Releases](https://github.com/rgsneddon/perccent-wallet/releases) / [Downloads](https://rgsneddon.github.io/perccent-wallet/downloads/) |
| Android | Setup APK on Releases / Downloads |
| iOS | Source + verified simulator build; signed IPA when `DEVELOPMENT_TEAM` + certificates exist |
| Web | `flutter build web --release` |

### Install (iOS from source)

```bash
git clone https://github.com/rgsneddon/perccent-wallet.git
cd perccent-wallet
flutter pub get
cd ios && pod install && cd ..
flutter build ios --simulator --debug
# or: flutter run -d ios
```

### Docs & legal

- [README.md](README.md) — MY PERC branding, iOS prerequisites and build commands
- [PRIVACY_POLICY.md](PRIVACY_POLICY.md) — iOS scope; Android-only biometric vault; camera for QR
- [LICENSE](LICENSE) — personal non-commercial grant covers iOS builds/installers; commercial use still requires a separate agreement
- [ios/SIGNING.md](ios/SIGNING.md) — Team ID and export options for IPA packaging

### Not in this release

- App Store Connect / TestFlight submission
- iOS Face ID credential vault (Android biometric path unchanged)
- Fake placeholder IPAs as release assets

### Checksums

Verify Windows and Android packages with the `.sha256` / `.sha512` sidecars on GitHub Releases before installing.
