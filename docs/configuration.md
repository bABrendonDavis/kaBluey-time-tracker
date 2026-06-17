# kaBluey — Configuration Reference

All configuration lives in `kabluey.ini` in your data folder (`Documents\kaBluey\` by default).
Settings are grouped into sections. Most settings are also editable via the in-app Settings dialog.

---

## Command-line flags

Run `kaBluey.exe --help` for a summary. The flags below are supported:

| Flag | Description |
|------|-------------|
| `--lite` | Force Lite mode — skips Entra ID join check and starts without enterprise features. |
| `--mode prod` | Production mode (default). |
| `--mode pre_release` | Pre-release mode — writes a dated marker as line 1 of every data file. |
| `--mode uat` | UAT mode — same as pre_release, plus loads a separate INI file via `uat_ini_path`. |

---

## [settings] section

### User

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `email` | *(blank)* | Yes — User tab | Your work email address. **Mandatory** — app will not start until set. Used to label time entries and identify your M365 account. |
| `role_type` | *(blank)* | Yes — User tab | Your job role or title. **Mandatory** — app will not start until set. Included in time log labels. |

### Timing

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `prompt_interval_minutes` | `15` | Yes — Timing tab | How often (in minutes) the prompt appears. Options: 10, 15, 20. |
| `prompt_timeout_seconds` | `20` | Yes — Timing tab | How long the prompt waits for a response before auto-accepting (1–600 seconds). |
| `interruption_minutes_default` | `5` | Yes — Timing tab | Default duration (minutes) of an interruption block. |
| `sleep_detection_seconds` | `300` | Yes — Timing tab | Gap threshold (seconds) above which a missed prompt is treated as a sleep/away event. |
| `contracted_hours_per_day` | `07:36` | Yes — Timing tab | Your contracted daily hours (HH:MM). Drives the daily progress banner in the editor. |

### Schedule

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `prompt_stop_time` | `17:00` | Yes — Schedule tab | Stop prompting at this time (HH:MM, 24-hour). |
| `next_day_start_time` | `09:00` | Yes — Schedule tab | Resume prompting at this time the next day (HH:MM, 24-hour). |

### Sound

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `enable_sound` | `true` | Yes — Sound tab | Play an alert sound when the prompt appears. |
| `sound_file` | `assets/kaBluey_ding.wav` | Yes — Sound tab | Path to a WAV file to play as the alert. |

### Work types

| Key | Default | Settings dialog | Description |
|-----|---------|-----------------|-------------|
| `labour_type1` … `labour_type9` | Pre-defined categories | Yes — Work Types tab | The 9 selectable work-type labels shown as radio buttons in the prompt and editor. |

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
| `m365_override_client_id` | *(blank)* | Override the built-in Microsoft 365 Azure AD app Client ID. Enterprise deployments with their own app registration set this. |
| `m365_override_tenant_id` | *(blank)* | Override the built-in Azure AD Tenant ID. Use your organisation's domain or GUID, or `common` for multi-tenant. |
| `m365_use_file_token_cache` | `false` | Store M365 auth tokens as a local JSON file instead of Windows Credential Manager. Only enable if the OS credential store is unavailable. |
| `date_override` | *(blank)* | Override the date used for log entries. Format: `DD-MM` (e.g. `03-06` for 3 June). For testing/audit use only. |
| `root_directory` | *(blank)* | Root directory for all kaBluey data. Overrides all relative path resolution. |
| `job_list_directory` | *(blank)* | Separate location for the job list file. Blank = same as `data_directory`. |
| `enterprise_flag_path` | *(blank)* | **macOS only.** Full path to an MDM-deployed marker file. If present and security checks pass, enables Full mode. |
| `dark_mode` | *(blank)* | Override OS theme detection: `light` or `dark`. Blank = follow OS setting. |
| `lite_override` | *(blank)* | **UAT mode only.** Force `full` or `lite` tier regardless of Entra ID detection. |
| `uat_ini_path` | *(blank)* | **UAT mode only.** Load a separate INI file instead of the default `kabluey.ini`. |
| `draft_status` | `true` | Upload SharePoint entries as drafts rather than published items. (SharePoint integration not yet wired.) |

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
    └── m365_cache_<email>.json    # M365 token cache (only if file cache enabled)
```
