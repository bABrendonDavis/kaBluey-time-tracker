# Security Scanning in kaBluey Development

kaBluey integrates two automated security scanning tools into its end-of-day (EOD) routine.
Scans run **before** any compile or push, blocking releases on confirmed CVEs.

---

## Tools

### pip-audit — Dependency CVE scanning

**Package:** `pip-audit` 2.10.1  
**What it does:** Checks the packages in `requirements.txt` **and every package in the hash-locked build environments** (`requirements-build-win.lock`, `requirements-build-mac.lock` - direct and transitive) against the [OSV](https://osv.dev) vulnerability database (which includes CVE data from NVD, GitHub Advisories, and PyPI advisories).  
**Run manually:**
```
python -m pip_audit -r kaBluey/requirements.txt
python -m pip_audit -r kaBluey/requirements-build-win.lock --require-hashes --no-deps --disable-pip
```

**EOD behaviour:** If any vulnerability is found, the PyInstaller compile step is **blocked** and a deviation entry is written to `.aiaudit/`.

---

### Semgrep — Static application security testing (SAST)

**Package:** `semgrep` 1.183.0  
**What it does:** Static analysis of Python source code using the `p/python` rule set. Detects common security issues such as unsafe subprocess usage, SQL injection patterns, hardcoded secrets, and insecure deserialization.  
**Run manually:**
```
semgrep --config p/python kaBluey/
```

**EOD behaviour:** Findings are reported as warnings. They do **not** block the commit or push, but are logged to `.aiaudit/` for review before release.

---

## Integration in the EOD Routine

The security scan runs as **Step 3 of 11** in `routines/eod.py`, after the dep_check (Step 2) and before the changelog check (Step 4).

```
Step 1  — Full test suite
Step 2  — dep_check (Rules 5 + 6)
Step 3  — Security scan: pip-audit + Semgrep   ← NEW
Step 4  — Changelog verification
Step 5  — Version bump (BUILD++)
Step 6  — Git commit
Step 7  — SHA256SUMS generation
Step 8  — GPG sign
Step 9  — Git push
Step 10 — Release build (compile + smoke test)
Step 11 — Weekly audit summary (Fridays)
```

The standalone scanner can also be run at any time:
```
python routines/security_check.py
```

---

## Checksum verification (Rule 2)

Per workspace governance Rule 2, SHA256 checksums of security tool packages were verified against PyPI metadata before installation:

| Package | Version | File | SHA256 | Verified |
|---------|---------|------|--------|----------|
| semgrep | 1.183.0 | `semgrep-1.183.0-...-win_amd64.whl` | `8e9d96b9...` | 2026-11-05 |
| pip-audit | 2.10.1 | `pip_audit-2.10.1-py3-none-any.whl` | `99ef3f60...` | 2026-11-05 |

Both hashes match PyPI JSON metadata exactly.

The packages bundled into kaBluey and the build tools are checked the same way: every entry in the build
locks carries its SHA-256, verified against PyPI's published digests when the lock is generated and again
in CI (`build_env.py lock` / `verify-lock`).

---

## Scope

Scanning covers the `kaBluey/` source directory, `kaBluey/requirements.txt` and the build locks. Development-only tools (semgrep, pip-audit, pytest) are not part of the build environment and are not bundled in the compiled exe: release builds run from a separate, hash-locked virtual environment that contains only the locked packages.

## 1.0 status

| Check | Result for 1.0 |
|-------|----------------|
| Semgrep `p/python` over `kaBluey/` | 0 findings (intentional uses carry a written justification) |
| pip-audit, `requirements.txt` and both build locks | no known vulnerabilities |
| `dep_check` (freshness + OSV for every locked package + CLDR drift) | clean; build-only helper packages that have not released in 12 months are reported as warnings, never bundled |
| Third-party GitHub Actions | pinned by commit SHA |
