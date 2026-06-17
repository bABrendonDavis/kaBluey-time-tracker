# kaBluey — Changelog

All notable changes. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [0.6.4] — 2026-06-16 — Build 29

Feature expansion (Groups A–N), two UI fixes, and a privacy policy.

### Added
- Mandatory startup gate — email and role_type must be set before the app continues
- `role_type` setting and `contracted_hours_per_day` setting, with a live daily progress banner
- Frequent-jobs combobox backed by a full Outlook + local job pool; "..." dialog searches and adds from the full pool
- Category-based Outlook Tasks sync (`tasks_download` / `tasks_upload` / `tasks_category`) — requests `Tasks.ReadWrite` only when a Tasks toggle is enabled
- Calendar preview panel in the editor — shows today's Outlook events, colour-codes them, and creates a time-log entry when ticked
- `calendar_sync_enabled`, `calendar_upload_category`, `calendar_exclude_categories`, `calendar_target_calendar` settings
- Labour-type search combobox alongside existing radio buttons
- `outlook_importance` setting applied to all calendar events created by kaBluey
- `PRIVACY_POLICY.txt` — Microsoft Store-compliant privacy policy

### Changed
- Editing an older date now ring-fenced to the past 10 days
- Open Settings dialog dismissed automatically before a check-in prompt appears
- Prompt Yes button always extends the last log entry's stop time

### Fixed
- Dark-mode listbox contrast — panels now adapt to OS light/dark theme
- Keyboard shortcut hints reformatted as boxed `[Key]` chips

---

## [0.6.3] — 2026-06-16 — Build 28

### Added
- Unit test suite (`tests/` directory)
- Weekly report — right-click Create menu → "Create end of week report" / "Create last week's report"
- Banner spinner in the editor
- Notes placeholder text when notes is empty (reminds users the note may be visible in calendar)
- 5-colour listbox scheme adapting to OS light and dark mode

### Changed
- Prompt auto-accept now fires "Yes" (continue same activity) instead of "No"
- Context menu "Change timer interval…" renamed to "Settings"
- Unknown entries renamed to "Unconfirmed"
- Synced entries shown in grey; right panel locked read-only for synced entries
- `log_retention_days` default changed from 60 → 14 days; maximum enforced at 90 days
- Keyboard shortcut: Insert = new blank entry; Enter in notes = Update + advance; Shift+Enter = newline

---

## [0.6.2] — 2026-06-15 — Build 27

### Added
- Governance framework (internal)
- Daily routine scripts (internal)

---

## [0.6.1] — 2026-06-13 — Build 26

### Added
- `dep_check.py` — monthly dependency health checker (PyPI freshness + OSV vulnerability scan)

### Changed
- All dependencies pinned with `==version` constraints

---

## [0.6.0] — 2026-06-11 — Build 23

### Added
- Keyring integration — M365 auth tokens stored via Windows Credential Manager (macOS Keychain on Mac); file-based fallback via `m365_use_file_token_cache`
- Full / Lite tier system — enterprise features gated on Entra ID join status
- Log rotation — `log_retention_days` INI key (default 60 days → changed to 14 in 0.6.3)

---

## [0.5.2] — 2026-06-09 — Build 21

### Added
- GitHub repository files: LICENSE, CHANGELOG, CONTRIBUTING, SECURITY policy
- GitHub Actions CI workflow (lint + unit tests)
- Expanded README with installation, configuration, and build instructions

---

## [0.5.1] — 2026-06-09

### Added
- Initial upload to GitHub
- Platform-specific code for Windows and macOS
- Microsoft 365 / Graph API integration
- PyInstaller build specification

---

## [0.5.0] — 2026-06-09

Initial release of base functioning code.

- Core time-tracking loop with clock-aligned interval prompts
- Configurable INI-based settings
- Persistent log storage
- System tray icon
- Tkinter-based prompt and editor windows
