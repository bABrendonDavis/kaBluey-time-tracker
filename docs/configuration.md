# kaBluey — Configuration Reference

All configuration lives in `kabluey.ini` in your data folder (`Documents\kaBluey\` by default).
Settings are grouped into sections. Most settings are also editable via the in-app Settings dialog.

---

## Command-line flags

Run `kaBluey.exe --help` for a summary. The flags below are supported:

| Flag | Description |
|------|-------------|
| `--lite` | Force Lite mode — skips Entra ID join check and starts without enterprise features. |
| `--check-updates` | Check GitHub for a newer kaBluey release now (the same check as `update_check_enabled`, for this run only). |
| `--debug` | Write a full DEBUG log to `<log_dir>/<DD-MM>kaBlueyDebug.log` and echo it to the console. |
| `--config PATH` | Path to `kabluey.ini` (default `Documents\kaBluey\kabluey.ini`). |
| `--data-dir DIR` | Override the data/log directory. |
| `--mode prod` | Production mode (default). |
| `--mode pre_release` | Pre-release mode — writes a dated marker as line 1 of every data file. |
| `--mode uat` | UAT mode — same as pre_release, plus loads a separate INI file via `uat_ini_path`. |

### Hidden CLI flags (not shown in --help)

These flags are for development and integration testing. They are not documented in the in-app help.

| Flag | Description |
|------|-------------|
| `--simple` | Reserved. The flag is accepted for compatibility but currently has no effect. |

---

## [settings] section

### User

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `email` | *(blank)* | Yes — User | Your work email address. **Mandatory** — app will not start until set. Used to label time entries and identify your M365 account. |
| `role_type` | *(blank)* | Yes — User | Your job role or title. **Mandatory** — app will not start until set. Included in time log labels. |

### Timing

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `prompt_interval_minutes` | `15` | Yes — Timing | How often (in minutes) the prompt appears. Options: 10, 15, 20. |
| `prompt_timeout_seconds` | `20` | Yes — Timing | How long the prompt waits before closing (1–600 seconds). An unanswered prompt becomes an `Unconfirmed` entry to fill in later. |
| `interruption_minutes_default` | `5` | Yes — Timing | Default duration (minutes) of an interruption block. |
| `sleep_detection_seconds` | `300` | Yes — Timing | Gap threshold (seconds) above which a missed prompt is treated as a sleep/away event. |
| `contracted_hours_per_day` | `07:36` | Yes — Timing | Your contracted daily hours (HH:MM). Drives the daily progress banner in the editor. |

### Schedule

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `prompt_stop_time` | `17:00` | Yes — Schedule | Stop prompting at this time (HH:MM, 24-hour). |
| `next_day_start_time` | `09:00` | Yes — Schedule | Resume prompting at this time the next day (HH:MM, 24-hour). |

### Sound

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `enable_sound` | `true` | Yes — Sound | Play an alert sound when the prompt appears. |
| `sound_file` | `assets/kaBluey_ding.wav` | Yes — Sound | Path to a WAV file to play as the alert. |

### Work types

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `labour_type1` … `labour_type9` | Pre-defined categories | Yes — Labour Types | The 9 selectable work-type labels shown as radio buttons in the prompt and editor. |

### Files and logs

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `log_file_name` | `kaBlueyTimeLogs.txt` | Yes — Advanced | Suffix for daily log filenames. Files are named `DD-MM-<log_file_name>`. |
| `job_list_file` | `my-kabluey-jobs.txt` | Yes — Advanced | Filename for your local job/ticket list. |
| `data_directory` | `~/Documents/kaBluey` | Yes — Advanced | Primary data folder. Blank = default location. |
| `log_directory` | *(blank = data_directory)* | Yes — Advanced | Where log files are written. Blank = same as `data_directory`. |
| `log_retention_days` | `14` | Yes — Advanced | Auto-delete log files older than this many days (1–90). |

### Calendar

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `calendar_sync_enabled` | `false` | Yes — Advanced | Show the calendar preview panel and enable daily event fetching from Outlook. |
| `calendar_upload_category` | *(blank)* | Yes — Advanced | Outlook category applied to entries created from the calendar preview panel. |
| `calendar_exclude_categories` | *(blank)* | Yes — Advanced | Comma-separated Outlook categories to hide from the calendar preview panel. |
| `calendar_target_calendar` | *(blank)* | Yes — Advanced | Specific named Outlook calendar to read from. Blank = default mailbox calendar. |

### Outlook Tasks sync

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `tasks_download` | `false` | Yes — Advanced | Pull Outlook Tasks tagged with `tasks_category` into the local job pool. Requests `Tasks.ReadWrite` scope. |
| `tasks_upload` | `false` | Yes — Advanced | Push locally-added jobs back to Outlook Tasks, tagged with `tasks_category`. Requests `Tasks.ReadWrite` scope. |
| `tasks_category` | `kaBluey` | Yes — Advanced | Outlook category used to tag and filter kaBluey's Tasks sync. |

### Outlook calendar event options

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `outlook_category` | *(blank)* | Yes — Advanced | Outlook category applied to all calendar events created by kaBluey. |
| `outlook_free_busy` | *(blank = Busy)* | Yes — Advanced | Free/busy status on created calendar events: `free`, `busy`, `tentative`, `oof`, `workingElsewhere`. |
| `outlook_importance` | `normal` | Yes — Advanced | Importance flag on created calendar events: `low`, `normal`, `high`. |
| `verify_m365_upload` | `false` | Yes — Advanced | GET each created calendar event after upload to confirm it exists. Adds one extra API call per entry. |
| `frequent_jobs_count` | `12` | Yes — Advanced | Number of favourite jobs shown in the editor's Job dropdown. |

---

## Hidden INI keys (not in Settings dialog — add manually if needed)

| Key | Default | Description |
|-----|---------|-------------|
| `m365_override_client_id` | *(blank)* | Leave blank to use kaBluey's production release app registration (a multi-tenant public client — an identifier, not a secret). Set only if your organisation requires its own internal app registration. |
| `m365_override_tenant_id` | *(blank)* | Directory (tenant) ID or domain, or `common`; used together with `m365_override_client_id` for an internal app registration. |
| `m365_enhanced_security` | `false` | Windows: also store the token file's DPAPI decryption secret in Windows Credential Manager, so decryption needs both your Windows login and that entry. |
| `m365_use_file_token_cache` | `false` | Store M365 auth tokens as an **unencrypted** JSON file instead of the secure default (a DPAPI-encrypted file on Windows / the OS keychain on macOS). Only enable if secure storage is unavailable. |
| `date_override` | *(blank)* | Override the date used for log entries. Format: `DD-MM` (e.g. `03-06` for 3 June). For testing/audit use only. |
| `root_directory` | *(blank)* | Root directory for all kaBluey data. Overrides all relative path resolution. |
| `job_list_directory` | *(blank)* | Separate location for the job list file. Blank = same as `data_directory`. |
| `enterprise_flag_path` | *(blank)* | **macOS only.** Full path to an MDM-deployed marker file. If present and security checks pass, enables Full mode. |
| `dark_mode` | *(blank)* | Override OS theme detection: `light` or `dark`. Blank = follow OS setting. |
| `ini_download_url` | *(blank)* | Set by an administrator: the INI is fetched from this URL at startup and merged into the local file. A SHA-256 sidecar must be published at `<url>.sha256`; the import is skipped if it is missing or does not match. |
| `update_check_enabled` | `false` | Check GitHub for a newer release at startup (opt-in). |
| `after_hours_mode` | `false` | Keep prompting outside normal working hours. |
| `working_days` | `mon,tue,wed,thu,fri` | Comma-separated working days. |
| `job_autosort` | `true` | Move the last-used job to the top of the job list on each Update. |
| `tasks_list_name` | `kaBluey` | Microsoft To Do list used for kaBluey's tasks. |
| `calendar_export_enabled` | `false` | Export confirmed time entries to your Outlook calendar. |
| `lite_override` | *(blank)* | **UAT mode only.** Force `full` or `lite` tier regardless of Entra ID detection. |
| `uat_ini_path` | *(blank)* | **UAT mode only.** Load a separate INI file instead of the default `kabluey.ini`. |
| `draft_status` | `true` | Reserved — currently has no effect. |

---

## Auto-saved keys (written by the app — do not edit manually)

| Key | Description |
|-----|-------------|
| `main_window_width` | Last window width in pixels. |
| `main_window_height` | Last window height in pixels. |
| `main_window_sash` | Last sash (divider) position in the editor. |

---

## Log file format

Daily log files are named `DD-MM-<log_file_name>` (e.g. `17-06-kaBlueyTimeLogs.txt`).

Each line is one time entry:

```
[* ]HH:MM ; HH:MM ; ticket_name ; labour_type ; notes
```

- `* ` prefix — entry has been synced to Outlook (leading asterisk + space)
- `HH:MM ; HH:MM` — start time ; stop time (24-hour)
- `ticket_name` — job or ticket name
- `labour_type` — one of the 9 configured work types, or `Private`
- `notes` — free-text notes (may be blank)

Example:
```
09:00 ; 09:15 ; Stand-up ; Internal ; Daily team stand-up
* 09:15 ; 10:30 ; PRJ-123 ; Development ; Refactored auth module
```

---

## Data folder layout

```
Documents\kaBluey\
├── kabluey.ini                    # All settings
├── my-kabluey-jobs.txt            # Local job/ticket list
├── 17-06-kaBlueyTimeLogs.txt      # Today's log (DD-MM format)
├── 16-06-kaBlueyTimeLogs.txt      # Yesterday's log
└── assets\
    ├── all-kabluey-jobs.csv       # Full job pool (local + Outlook Tasks)
    ├── calendar_YYYY-MM-DD.json   # Cached calendar events (temporary)
    ├── m365_cache_<email>.bin     # M365 token cache (DPAPI-encrypted, Windows default)
    └── m365_cache_<email>.json    # M365 token cache (only if legacy file cache enabled)
```
