# kaBluey — Changelog

All notable changes. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [0.8.6] — 2026-07-27 — Build 59

macOS parity pass: automatic Full-mode detection, a working light/dark switch, and
platform-owned window sizing. Windows behaviour is unchanged throughout — every change
is either macOS-gated or additive.

This is the build packaged for the Microsoft Store as `0.8.6.0`.

### Fixed
- Light/dark switching now applies without restarting the app — the saved theme is re-applied
  before the main window is rebuilt, and any other open window (prompt pop-up, daily/weekly
  summary) is repainted at the same time
- macOS dark mode no longer renders half-light: buttons and scrollbars now build from ttk on
  macOS so they follow the system appearance. Windows and Linux keep their existing widgets
- macOS widgets now follow the app theme instead of showing a frame-vs-widget colour split
- Cancelling the Settings dialog after previewing a theme reverts to the saved theme

### Added
- Automatic Full mode on managed Macs — MDM enrolment (Intune, Jamf, any vendor) is detected
  and activates Full mode, matching the existing Entra-join check on Windows. Existing
  deployments using the enterprise flag file are unaffected
- macOS installers: the build now produces a `.pkg` alongside the `.dmg`, installing to
  `/Applications` on double-click

### Changed
- Default window sizes now adapt per platform. Windows keeps its exact historic dimensions;
  macOS gets proportionally larger main, Settings, summary and prompt windows to suit Aqua's
  control metrics and system font

---

## [0.8.3] — 2026-07-23 — Build 57

macOS platform-abstraction pass. Windows behaviour is unchanged throughout.

### Fixed
- Settings now opens from the main window on macOS
- Mouse-wheel scrolling works across the app on macOS, including the calendar panel and the
  main entry list
- Per-item right-click "sync flag" now toggles by the entry's actual state rather than a
  fixed action
- The prompt fallback clock emoji renders in the real macOS colour-emoji font

### Added
- Editor sync-eligibility gate plus a "Same as last" merge button on the Quick Edit panel
- Job pool gains a Remove button; the quick-edit button switches with the current selection
- Outlook Tasks job titles may now contain `#`
- macOS keyboard shortcuts — Cmd+Z / Cmd+S / Cmd+D / Cmd+A / Cmd+C alongside the existing
  Ctrl equivalents, which keep working everywhere
- macOS right-click: the entry list responds to trackpad Control-click as well as Button-3

### Changed
- All modal dialogs now route through a shared helper, so none can silently fail to display
  when opened over a hidden parent

---

## [0.8.2] — 2026-07-21 — Build 55

### Fixed
- macOS: kaBluey no longer aborts on Tcl/Tk 9.0 + macOS 26 (Tahoe) with an
  `unrecognized selector` error at startup

### Changed
- macOS dark-mode detection now reads the system setting in-process rather than spawning a
  subprocess on the GUI thread

---

## [0.8.1] — 2026-07-16 — Build 54

### Added
- Kablammo browser sign-in — sign in through your browser via device authorization, alongside
  the existing pair-code entry
- Token-expiry hygiene: an expired or rejected token is cleared automatically rather than
  causing repeated sync failures

---

## [0.8.0] — 2026-07-14 — Build 52

### Fixed
- Microsoft 365 sign-in now persists on Windows. The MSAL token cache exceeded Windows
  Credential Manager's blob size limit, forcing a fresh device-code sign-in on every launch.
  The token is now stored as a **DPAPI-encrypted file** bound to your Windows account — the
  approach Microsoft's own tooling uses. macOS and Linux continue to use the OS keychain
- Error and information pop-ups are now selectable and copyable, with a Copy button

### Added
- Optional "Enhanced security" setting (Windows) — also stores the token file's decryption
  secret in Windows Credential Manager, so decryption requires both your Windows login and
  that entry
- Standard Windows text-editing behaviours across all input fields: Ctrl+A, Ctrl+Insert /
  Shift+Insert / Shift+Delete, and Ctrl+Backspace / Ctrl+Delete. Read-only forms now support
  select and copy without being editable
- SHA-256 sidecar verification for remote file imports — the remote INI fetch and labour-types
  CSV download now require a matching `.sha256` sidecar and abort on mismatch. Never applied
  to local files or to push/pull sync
- Help is now a single self-filtering page, opening summarised to your platform and tier with
  a "Show everything" toggle, plus a command-line switch reference
- Kablammo sync as an **additional** destination for Full-mode users, usable alongside
  Microsoft 365 rather than replacing it. An entry is marked synced only once every active
  destination confirms it
- 3-level labour types (Major › Minor › Type)
- Opt-in update check comparing the running version against the latest GitHub release
- Daily Summary report, plus `<` / `>` navigation in both daily and weekly summary dialogs
- Native month-grid date picker replacing the abandoned tkcalendar dependency

### Changed
- Right-click menu options now grey out when their preconditions fail rather than failing
  silently on click

---

## [0.7.4] — 2026-07-06 — Build 50

### Fixed
- Yesterday/tomorrow viewing mode no longer surfaces current-day scheduled-event alerts
- Start time is taken exactly as typed (no AM/PM auto-correction); stop time auto-corrects
  relative to start only
- Fill Gaps now creates discrete 15-minute blocks per gap and re-sorts
- Shift+Tab from the labour-type quick-edit list returns to the labour search box
- Settings Save reopens the main window immediately, so the sync button and banner reflect a
  fresh Microsoft 365 sign-in without re-prompting
- Factory Reset no longer fails with a file-in-use error on Windows
- New Unconfirmed entries no longer inherit the previous entry's labour type

### Added
- Log files now include a `# date: DD-MM` header row for import referencing
- Single-instance guard — a second kaBluey process shows a notice and exits
- Private-flagged calendar appointments sync as bare "Private" with no subject, location or body
- Calendar sync includes events that start *or* stop within working hours
- kaBluey's own category-tagged events are excluded from calendar sync-down
- Tab into a time field selects all text for quick overwrite
- Advanced setting "Allow legacy file-based credential storage" (default off) — keyring
  failures now surface a Credential storage error instead of silently falling back to a
  plaintext file cache

### Changed
- Tooltip delay reduced 1500 ms → 700 ms; tooltips added to the Advanced toggle, Factory
  Reset, and weekly-report Copy buttons
- Pillow updated 12.2.0 → 12.3.0

---

## [0.7.2] — 2026-06-25 — Build 42

### Fixed
- kaBluey.exe now declares PerMonitorV2 DPI awareness in its embedded application manifest,
  resolving Windows App Certification Kit Test 92
- MSIX SplashScreen asset corrected to 620×300, resolving WACK Test 45
- Number keys 1–9 are no longer intercepted by the labour-type shortcut when focus is in a
  text input — digits type normally in Start, Stop, Job and Notes
- Tab now saves the current entry and moves through the quick-edit fields (Start → Stop → Job
  → Labour → Notes → Update) instead of advancing the list selection
- Tab into Notes places the cursor at the end of existing text rather than selecting all
- Labour-type radio labels display only the Minor part, handling both the canonical `›`
  separator and legacy `|` in hand-edited INI files
- Entries with ticket `Unconfirmed` display in the same orange colour as incomplete entries
- Entries with a blank ticket are excluded from the daily contracted-hours progress percentage

---

## [0.7.1] — 2026-06-30 — Build 44

### Fixed
- Time log list no longer auto-sorts on focus change — sorting triggers on Update only
- Delete-and-Exit now correctly terminates the application process
- First-launch tray-icon notice is non-blocking
- Theme on launch honours the INI `theme` setting rather than always following OS dark mode
- Favourite Labour Types are auto-populated with the top 9 from the imported default file on
  first launch, replacing hardcoded values
- Day-rollover re-activates prompts and starts the spinner
- Time calculation corrected — hours and minutes no longer confused
- Pop-up windows no longer steal keyboard focus from the active window
- Debug log correctly rolls over on day change
- Time entry `0015` parses as `00:15` rather than `12:15`
- Finish time fires after the final scheduled trigger completes, not before
- Jobs dropdown re-sorts on Update, moving the last-used job to the top
- Manage Jobs window follows light/dark theme, is resizable, and persists its size

### Added
- Auto-sort toggle button on the Jobs box (enabled by default)
- INI HTTP source setting — on first load, if `ini_download_url` is set the app fetches and
  saves an INI from that URL
- Countdown timer on the check-in prompt replaced with a depleting circular pie-chart

### Changed
- Outlook defaults updated: free/busy `Free`, calendar category `kaBluey`; free/busy is now a
  dropdown (Free / Tentative / Busy / Out of Office)
- `keep_logs_days` default changed to 20
- Todo sync places items in general tasks only

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
