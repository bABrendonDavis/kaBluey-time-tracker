# kaBluey — Microsoft Store Compliance Audit (Refresh)
**Date:** 2026-06-23
**Supersedes:** `store-compliance-2026-06-17.md` (audited v0.6.4 Build 29)
**App version audited:** 0.7.1 Build 32 (current release exe)
**Policy version:** Microsoft Store Policies v7.19 (effective 2025-10-14)
**Auditor perspective:** Microsoft Store certification reviewer (individual publisher, free app, private/direct-link listing)

---

## Phase 0 — Blocking decisions

| Ref | Decision | Status |
|-----|----------|--------|
| 0-A | Publisher name | **RESOLVED: Brendon Davis** |
| 0-B | Azure AD App Registration — `M365_CLIENT_ID` / `M365_TENANT_ID` placeholders | **OPEN — awaiting GUIDs from dev tenant registration** |
| 0-C | Privacy policy URL | **RESOLVED: `https://bABrendonDavis.github.io/kaBluey-time-tracker/privacy-policy.html`** — GitHub Pages must be confirmed live |
| 0-D | Packaging path | **RESOLVED: MSIX** |

---

## Phase 1 — Compliance gap findings (refreshed)

### CRITICAL

| ID | Policy | Finding | Required Action | Done |
|----|--------|---------|-----------------|------|
| 1-A | 10.5.1 | Privacy policy must be a hosted URL in Partner Center. | `docs/privacy-policy.html` exists. GitHub Pages must be confirmed live at the URL above. | [~] Pending Pages confirmation |

### REQUIRED

| ID | Policy | Finding | Required Action | Done |
|----|--------|---------|-----------------|------|
| 1-B | 11.11 | IARC age rating questionnaire. | Complete in Partner Center during submission. No code change. Expected: PEGI 3 / Everyone. | [ ] PC action |
| 1-C | 10.2.7 | Uninstall data note. | ✓ In `store-assets/store-description.md` full description and `assets/kabluey_help.html`. | [x] |
| 1-D | 10.3.1 | Certification team testing instructions. | ✓ Notes for certification draft in `store-assets/store-description.md`. Update before submission to reference v0.7.1. | [x] |
| 1-E | Checklist | ≥4 screenshots + 300×300 Store logo. | Screenshots dir empty. Logo not produced. **Must complete before submission.** | [ ] |
| 1-F | 10.1.2 / 10.4.2 | First-run mandatory field gate. | ✓ Implemented: Settings auto-opens when email/role_type blank. Verified in v0.7.1. | [x] |
| 1-H | 10.5.4 | M365 Client ID placeholder in `kabluey.py`. | Resolve 0-B before Store build. Blocked. | [ ] |

### CONDITIONAL

| ID | Policy | Finding | Required Action | Done |
|----|--------|---------|-----------------|------|
| 1-G | 10.6 | MSIX container file access (`Documents\kaBluey\`). | Test after MSIX wrap. Declare `internetClient` + `documents` capability. | [ ] |

### ADVISORY (resolved)

| ID | Status |
|----|--------|
| 1-I M365 Disconnect button | ✓ Implemented in v0.7.1 Settings dialog. |

---

## Phase 2 — Pre-submission source changes

| Step | Task | Status |
|------|------|--------|
| 2-A | Replace `M365_CLIENT_ID`/`M365_TENANT_ID` in `kabluey.py` | [ ] Blocked on 0-B |
| 2-B | `assets/kabluey_help.html`: weekly-report, uninstall, disconnect sections | [x] Done in v0.7.1 |
| 2-C | Smoke-test compiled exe: Settings auto-opens on blank fields | [ ] Needs exe build |
| 2-D | `python routines/eod.py --release`: dep_check + compile + SHA256 + sign | [ ] Needs 2-A |
| 2-E | MSIX packaging + install/uninstall test + data folder test | [ ] Needs 2-D |
| 2-F *(new)* | **version_info.txt**: set `CompanyName = 'Brendon Davis'`, `LegalCopyright = 'Copyright 2026 Brendon Davis'` | [x] Done 2026-06-23 |
| 2-G *(new)* | **NOTICES.txt** in kaBluey source tree bundled with MSIX | [x] Done 2026-06-23 |

---

## Phase 3 — Public repo (`kaBluey-time-tracker`) checklist

| File | Status |
|------|--------|
| `README.md` | [x] |
| `docs/privacy-policy.html` | [x] — 3 blueAPACHE refs replaced with "Brendon Davis" (2026-06-23) |
| `docs/changelog.md` | [x] — update to cover v0.7.1 |
| `docs/configuration.md` | [x] — review for v0.7.1 new keys |
| `docs/notices.html` *(new)* | [ ] — open source attribution for GitHub Pages |
| `docs/m365-setup.md` *(new)* | [ ] — Azure AD app registration guide |
| `releases/v0.7.1/kaBluey.msix` | [ ] |
| `releases/v0.7.1/SHA256SUMS.txt` | [ ] |
| `store-assets/screenshots/` (4+ PNG files) | [ ] |
| `store-assets/icon-300x300.png` | [ ] |
| `store-assets/store-description.md` | [x] — minor update for v0.7.1 features |
| GitHub Pages live and returning 200 | [ ] — confirm |

---

## Phase 4 — Partner Center submission checklist

| Step | Done |
|------|------|
| Developer account created | [ ] |
| App name "kaBluey" reserved | [ ] |
| Privacy policy URL entered | [ ] |
| Category → Productivity | [ ] |
| IARC questionnaire complete | [ ] |
| MSIX package uploaded | [ ] |
| Store listing (description + screenshots + logo) | [ ] |
| Notes for certification submitted | [ ] |
| Submit for certification | [ ] |

---

## New items discovered since 2026-06-17

### N-1 — Open-source attribution (LGPL / MIT / Apache bundled libs)

kaBluey bundles the following under MSIX. Attribution must be accessible to users (Store T&C + individual licences).

| Component | Version | Licence | Action |
|-----------|---------|---------|--------|
| pystray | 0.19.5 | LGPL-3.0 | `NOTICES.txt` + LGPL offer statement |
| Pillow | 12.2.0 | HPND (MIT-like) | `NOTICES.txt` copyright |
| MSAL | 1.37.0 | MIT | `NOTICES.txt` copyright |
| requests | 2.34.2 | Apache-2.0 | `NOTICES.txt` + NOTICE text |
| keyring | 25.7.0 | MIT | `NOTICES.txt` copyright |
| PyInstaller | 6.21.0 | GPL-2.0 + bootloader exception | `NOTICES.txt` — bootloader exception permits distribution |
| python-docx | 1.2.0 | MIT | `NOTICES.txt` copyright (dev-only; not bundled in exe) |

**Deliverables:** `kaBluey/NOTICES.txt` (bundled) + `kaBluey-time-tracker/docs/notices.html` (GitHub Pages).

**LGPL pystray note:** User must be able to swap the library. Approach: include LGPL full text in NOTICES.txt and note that pystray is bundled as a frozen module inside the PyInstaller exe; a written offer to provide object files will be included in the notices.

### N-2 — Copyright / company name cleanup

`version_info.txt` has `CompanyName = 'blueAPACHE'` and `LegalCopyright = 'Copyright 2026 blueAPACHE / Brendon Davis'`. Windows PE resource must match the Partner Center Publisher identity ("Brendon Davis"). Change to `CompanyName = 'Brendon Davis'` and `LegalCopyright = 'Copyright 2026 Brendon Davis'` before the MSIX build.

`docs/privacy-policy.html` references "blueAPACHE" in 3 places — replace with "Brendon Davis".

### N-3 — docs/m365-setup.md

Enterprise users need a guide to register a multi-tenant Azure AD app and paste the GUIDs into `kabluey.ini`. This page does not exist yet.

### N-4 — Store-description update for v0.7.1

Add to feature list: multi-line notes, dark-mode support (was already mentioned but confirm wording).
Update Notes for certification to reference v0.7.1 and Build 32.

---

*Policy source: https://learn.microsoft.com/en-us/windows/apps/publish/store-policies (v7.19, 2025-10-14)*
