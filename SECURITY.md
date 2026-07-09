# Security policy — Perccent Wallet

## Release checks

Before each GitHub Release, maintainers run:

1. **`run security audit`** — `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_security_audit.ps1` (or workspace `run_security_audit.ps1` for both repos)
2. `scripts/scan_release_artifacts.ps1` — Defender scan + PE/APK integrity on `build/downloads/v*`
3. `scripts/audit_dependencies.ps1` — `flutter pub audit` + `npm audit --audit-level=high` in `perc_chain/`
4. Checksum sidecars generated during `build_installers.ps1` / publish

**Regular checks:** Run **run security audit** weekly or before any release publish. Manual device/network QA steps live in [MANUAL_TESTS.md](MANUAL_TESTS.md).

## Dependency audit exceptions

Document any unmitigated **critical** or **high** findings here with rationale and planned remediation.

### Documented exceptions

| Exception ID | Rationale |
|--------------|-----------|
| EX-dart_pub_audit_unavailable | Dart SDK 3.12.x lacks `dart pub audit`; `npm audit` on `perc_chain/` plus `flutter pub outdated` snapshot in audit logs (same policy as Evolve). |

## Reporting vulnerabilities

Email **russell.gray.sneddon@gmail.com** with reproduction steps.