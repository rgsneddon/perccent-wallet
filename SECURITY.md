# Security policy — Perccent Wallet

## Release checks

Before each GitHub Release, maintainers run:

1. `scripts/scan_release_artifacts.ps1` — Defender scan + PE/APK integrity on `build/downloads/v*`
2. `scripts/audit_dependencies.ps1` — `flutter pub audit` + `npm audit --audit-level=high` in `perc_chain/`
3. Checksum sidecars generated during `build_installers.ps1` / publish

## Dependency audit exceptions

Document any unmitigated **critical** or **high** findings here with rationale and planned remediation.

### Documented exceptions

| Finding | Rationale |
|---------|-----------|
| `dart pub audit` subcommand unavailable on Dart SDK 3.12.x | Same policy as Evolve: `npm audit` on `perc_chain/` plus `flutter pub outdated` snapshot in audit logs. Documented here per dependency audit exceptions policy. |

## Reporting vulnerabilities

Email **russell.gray.sneddon@gmail.com** with reproduction steps.