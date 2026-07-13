# MY PERC iOS signing inputs

Bundle ID: `com.perccent.perccentWallet` (see `Runner.xcodeproj`).

## Required Apple inputs

| Input | Where used |
|-------|------------|
| Apple Developer Program membership | Distribution / ad-hoc IPA export |
| Team ID (`DEVELOPMENT_TEAM`) | Xcode project + `ExportOptions.plist` |
| Distribution certificate | Release IPA signing |
| Provisioning profile for `com.perccent.perccentWallet` | `flutter build ipa` export |

Set Team ID locally:

```bash
export DEVELOPMENT_TEAM=XXXXXXXXXX
```

## Export options

`ios/ExportOptions.plist` defaults to `development` for local sideload testing.

## Build command (macOS + Xcode only)

```powershell
.\scripts\build_ios_installer.ps1
```

On Windows, `.\scripts\build_installers.ps1` skips IPA compile unless a staged IPA already exists.