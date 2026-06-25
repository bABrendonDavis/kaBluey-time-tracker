# Security Scanning in kaBluey Development

kaBluey integrates two automated security scanning tools into its end-of-day (EOD) routine.
Scans run **before** any compile or push, blocking releases on confirmed CVEs.

---

## Tools

### pip-audit — Dependency CVE scanning

**Package:** `pip-audit` 2.10.1  
**What it does:** Checks all packages in `requirements.txt` against the [OSV](https://osv.dev) vulnerability database (which includes CVE data from NVD, GitHub Advisories, and PyPI advisories).  
**Run manually:**
```
python -m pip_audit -r kaBluey/requirements.txt
```

**EOD behaviour:** If any vulnerability is found, the PyInstaller compile step is **blocked** and a deviation entry is written to `.aiaudit/`.

---

### Semgrep — Static application security testing (SAST)

**Package:** `semgrep` 1.167.0  
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
| semgrep | 1.167.0 | `semgrep-1.167.0-...-win_amd64.whl` | `b01823d9...` | 2026-06-23 |
| pip-audit | 2.10.1 | `pip_audit-2.10.1-py3-none-any.whl` | `99ef3f60...` | 2026-06-23 |

Both hashes match PyPI JSON metadata exactly.

---

## Scope

Scanning covers the `kaBluey/` source directory and `kaBluey/requirements.txt`. Development-only tools (semgrep, pip-audit, pytest) are not included in the production `requirements.txt` and are not bundled in the compiled exe.
