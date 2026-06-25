# kaBluey — Microsoft Store Listing Content

**Category:** Productivity
**Price:** Free
**Discoverability:** Not discoverable — direct link only

---

## App name

**kaBluey**

*(Must be unique in the Store — check availability when reserving the name in Partner Center.)*

---

## Short description (~270 characters)

> Lightweight Windows time-tracker that prompts you at regular intervals and syncs your entries to
> your Microsoft 365 Outlook calendar. Local-first, no telemetry, no ads.

Character count: ~175 — leaves room to add one more feature callout if needed.

---

## Full description

kaBluey is a lightweight time-tracking app for Windows that sits in your system tray and prompts
you at regular intervals to log what you are working on.

**How it works**
A small popup appears every 10, 15, or 20 minutes (your choice) and asks what you worked on.
Select a job, a work type, and add optional notes — then confirm in one click. The entry is added
to your daily log. At the end of the day you have a complete record of where your time went.

**Microsoft 365 integration (optional)**
Connect your Outlook calendar and kaBluey will upload your time entries as calendar events
automatically. You can also view today's calendar in the editor and tick events to create matching
time-log entries. Outlook Tasks sync is also available for keeping your job list in sync.

**Key features**
- Regular prompts at configurable intervals (10 / 15 / 20 minutes)
- System tray — runs quietly in the background, no taskbar clutter
- Daily log editor — view, edit, add, and delete entries for today
- Mandatory email and role fields — ensures entries are always labelled
- Daily progress banner — shows hours logged vs your contracted hours
- Weekly report — summarise the week grouped by job and work type
- Microsoft 365 sync — upload entries to Outlook calendar (optional)
- Calendar preview — tick today's Outlook events into your time log
- 9 configurable work-type categories
- Private entries — marked sensitive in Outlook so only you can see them
- Multi-line notes — add detailed notes to any time entry
- Dark mode — full light and dark theme support
- Local-first — all data stored on your device in plain-text files

**Privacy**
kaBluey has no servers, collects no analytics or telemetry, and does not show ads. The only
external connection is to Microsoft Graph when you opt in to Outlook sync — and that connection
is directly between your device and your own Microsoft 365 tenant.

**Uninstalling**
Uninstalling kaBluey removes the application. Your personal data (time logs and settings) is
stored in your Documents\kaBluey folder and is not deleted automatically — delete that folder
manually if you want to remove all data.

---

## Keywords (max 7, must be relevant — Policy 10.1.3)

1. time tracking
2. timesheet
3. Outlook calendar
4. Microsoft 365
5. productivity
6. work log
7. tray app

---

## Notes for certification (Partner Center field)

> kaBluey v0.7.1 Build 32 — works fully without a Microsoft 365 login. To test the app:
>
> 1. Launch the app. The Settings dialog opens automatically on first run.
> 2. Enter any email address and a role/job title in the User tab, then click Save.
> 3. The main editor and tray icon appear. The prompt fires at the configured interval.
> 4. All core features (time logging, editing, weekly report, multi-line notes) work without M365.
>
> Microsoft 365 sync (calendar and Tasks) is optional and off by default. To test it, sign in with
> any personal Microsoft account when prompted during the first sync attempt.
>
> The app runs in "Lite mode" on non-Entra-joined devices (default for personal machines).
> All consumer-facing features are available in Lite mode.
>
> To disconnect from Microsoft 365: Settings → Microsoft 365 tab → Disconnect.

---

## Store logo notes

- Required: 300×300 pixels, PNG
- Source: `assets/kaBluey.ico` — export the 256×256 layer, scale to 300×300
- Place export at: `store-assets/icon-300x300.png`

---

## Screenshot requirements

- At least 1 required; 4+ recommended
- Dimensions: 1366×768 or 1920×1080 (16:9), PNG or JPEG
- Suggested shots:
  1. Main editor with several log entries (shows daily progress banner)
  2. Prompt popup mid-session
  3. Settings dialog (User + Timing tabs visible)
  4. Calendar preview panel with events ticked

Place screenshots at: `store-assets/screenshots/screenshot-01.png` etc.

---

## Support contact

- URL: `https://github.com/bABrendonDavis/kaBluey/issues`
- Required for company accounts; recommended for individual accounts.
