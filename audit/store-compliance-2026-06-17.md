# kaBluey — Microsoft Store Compliance Audit
**Date:** 2026-06-17
**App version audited:** 0.6.4 Build 29
**Policy version:** Microsoft Store Policies v7.19 (effective 2025-10-14)
**Auditor perspective:** Microsoft Store certification reviewer (individual publisher, free app, private/direct-link listing)

---

## Phase 0 — Blocking decisions (developer must resolve)

| Ref | Decision | Recommendation | Status |
|-----|----------|----------------|--------|
| 0-A | **Publisher name** — "blueAPACHE" reads as a business entity (Policy 10.14). Individual account requires personal name. | Publish as "Brendon Davis"; list blueAPACHE as "Developed by" credit. | **RESOLVED: Brendon Davis** |
| 0-B | **Azure AD App Registration** — `M365_CLIENT_ID` and `M365_TENANT_ID` are placeholder strings. M365 sync non-functional in Store build until real GUIDs are set. | Register free multi-tenant Azure AD app; use Client ID + `'common'` tenant. | **RESOLVED: Developer registering multi-tenant app from dev tenant — awaiting GUIDs** |
| 0-C | **Privacy policy URL** — Partner Center requires a hosted URL, not a local file. | Host `docs/privacy-policy.html` via GitHub Pages on this repo. | **RESOLVED: GitHub Pages on this repo. URL: `https://bABrendonDavis.github.io/kaBluey-time-tracker/privacy-policy.html`** |
| 0-D | **Packaging path** — EXE direct-link requires EV code-signing cert (~$200–400/yr). MSIX path uses Microsoft Store signing (no cert cost). | Use MSIX Packaging Tool to wrap the PyInstaller exe. | **RESOLVED: MSIX** |

---

## Phase 1 — Compliance gap findings

### CRITICAL

| ID | Policy | Finding | Required Action | Done |
|----|--------|---------|-----------------|------|
| 1-A | 10.5.1 | Privacy policy must be a **URL** in Partner Center. `PRIVACY_POLICY.txt` is a local file only. Win32/Desktop Bridge apps always require this. | Convert to `docs/privacy-policy.html`, host via GitHub Pages. | [ ] |

### REQUIRED (will cause certification failure if unresolved)

| ID | Policy | Finding | Required Action | Done |
|----|--------|---------|-----------------|------|
| 1-B | 11.11 | IARC age rating questionnaire must be completed in Partner Center during submission. | Complete questionnaire. Expected rating: PEGI 3 / Everyone. No code change. | [ ] |
| 1-C | 10.2.7 | App must "clearly communicate" clean uninstall. Data in `Documents\kaBluey\` persists after uninstall — acceptable, but must be documented. | Add uninstall note to Store listing description and `kabluey_help.html`. | [ ] |
| 1-D | 10.3.1 | Certification team needs to test the app. M365 requires a Microsoft account. | In "Notes for certification": explain Lite mode works without M365; mandatory fields are email and role_type in Settings. | [ ] |
| 1-E | Checklist | Store listing requires: ≥1 screenshot (4+ recommended), description, category, Store logo. | Produce 4 screenshots + description + keywords + 300×300 logo. | [ ] |
| 1-F | 10.1.2 / 10.4.2 | App blocks on unset `email`/`role_type`. Certification team must not hit a silent failure on first run. | Verify Settings opens automatically if mandatory fields blank on first run. | [ ] |
| 1-H | 10.5.4 | `M365_CLIENT_ID = 'TO_BE_PROVIDED'` — M365 sync will error at auth if unresolved. | Resolve 0-B before Store build. | [ ] |

### CONDITIONAL (test during MSIX packaging)

| ID | Policy | Finding | Required Action | Done |
|----|--------|---------|-----------------|------|
| 1-G | 10.6 | MSIX container may block `Documents\kaBluey\` file access without explicit capability declaration. `documentsLibrary` is a restricted capability; `documents` (general) may suffice for Desktop Bridge. | Test data folder access post-MSIX packaging. Declare `internetClient` (required) + `documents` (probable). | [ ] |

### ADVISORY (post-submission improvement)

| ID | Policy | Finding | Suggested Action |
|----|--------|---------|-----------------|
| 1-I | 10.5.2 | No "Sign out of M365" UI. Users must manually clear Windows Credential Manager or delete `m365_cache_*.json`. | Add "Disconnect M365" button to Settings after Store launch. Document workaround in help for now. |

### NOT APPLICABLE — confirmed out of scope

| Policy | Reason |
|--------|--------|
| 10.8 Financial Transactions | No in-app purchases, no billing, no financial data collection |
| 10.10 Advertising | No ads |
| 10.13 Gaming / Xbox | Not a game |
| 10.2.1 Browser engine | Not a browser |
| 10.2.6 Cryptocurrency | Not applicable |
| 10.8.3 Financial account info | Not required — individual account permitted |

---

## Phase 2 — Pre-submission source changes (private kaBluey.git)

| Step | Task | Depends on | Done |
|------|------|-----------|------|
| 2-A | Replace `M365_CLIENT_ID`/`M365_TENANT_ID` placeholders in `kabluey.py:38–39` | 0-B resolved | [ ] |
| 2-B | Complete `assets/kabluey_help.html`: weekly-report section, uninstall data note, M365 sign-out workaround | — | [ ] |
| 2-C | Smoke-test compiled exe: verify Settings auto-opens when `email`/`role_type` blank on first run | — | [ ] |
| 2-D | `python routines/eod.py --release`: dep_check + compile + SHA256 + GPG sign; set `BETA_TAG = 'BETA 0.6.4'` | 2-A, 2-B, 2-C | [ ] |
| 2-E | MSIX packaging via MSIX Packaging Tool; test install/uninstall and data folder access | 2-D | [ ] |

---

## Phase 3 — Public repo (`kaBluey-time-tracker`) checklist

| File | Purpose | Done |
|------|---------|------|
| `README.md` | App overview, Store link, features | [ ] |
| `docs/privacy-policy.html` | Hosted privacy policy URL for Partner Center | [ ] |
| `docs/help.html` | Full help document (sync from kaBluey source) | [ ] |
| `docs/configuration.md` | All INI keys, CLI flags, hidden keys | [ ] |
| `docs/m365-setup.md` | Azure AD app registration guide for enterprise | [ ] |
| `docs/changelog.md` | Public changelog | [ ] |
| `releases/v0.6.4/kaBluey.msix` | Signed MSIX package | [ ] |
| `releases/v0.6.4/SHA256SUMS.txt` | Checksums | [ ] |
| `releases/v0.6.4/SHA256SUMS.txt.asc` | GPG signature | [ ] |
| `store-assets/screenshots/` | 4+ screenshots (1366×768 or 1920×1080) | [ ] |
| `store-assets/icon-300x300.png` | Store logo | [ ] |
| `store-assets/store-description.md` | Description, short desc, keywords draft | [ ] |
| GitHub Pages enabled on `/docs` | Privacy policy URL live | [ ] |

---

## Phase 4 — Partner Center submission checklist

| Step | Notes | Done |
|------|-------|------|
| Create developer account at storedeveloper.microsoft.com | Individual: MSA + government ID + selfie. Company: DUNS or incorporation docs. | [ ] |
| Reserve app name "kaBluey" | First-come; check availability. | [ ] |
| Pricing → Free | No price tier needed. | [ ] |
| Discoverability → "not discoverable in Store" | Direct link only — app won't appear in search or browse. | [ ] |
| Privacy policy URL | GitHub Pages URL from Phase 3. | [ ] |
| Category → Productivity | | [ ] |
| Age rating → complete IARC questionnaire | Expected: PEGI 3 / Everyone. | [ ] |
| Upload MSIX package | From Phase 2-E. | [ ] |
| Store listing | Description, screenshots, logo from `store-assets/`. | [ ] |
| Notes for certification | Lite mode explanation; mandatory first-run fields. | [ ] |
| Submit for certification | | [ ] |

---

## Key files in the private kaBluey.git repo relevant to this audit

| File | Relevance |
|------|-----------|
| `kabluey.py:38–39` | M365 Client ID / Tenant ID placeholders — must be replaced |
| `_platform_win.py` | Registry reads, dsregcmd, tray, dark-mode detection |
| `m365_graph.py` | All Graph API calls, OAuth scopes, token cache |
| `PRIVACY_POLICY.txt` | Source for `docs/privacy-policy.html` |
| `assets/kabluey_help.html` | Needs weekly-report + uninstall + M365 sign-out sections |
| `version.py` | Version 0.6.4 Build 29; BETA_TAG still 'BETA 0.6.2' |
| `kabluey.spec` | PyInstaller spec — base for MSIX packaging |

---

*Policy source: https://learn.microsoft.com/en-us/windows/apps/publish/store-policies (v7.19, 2025-10-14)*
*Submission checklist: https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/create-app-submission*
*Account types: https://learn.microsoft.com/en-us/windows/apps/publish/partner-center/open-a-developer-account*
