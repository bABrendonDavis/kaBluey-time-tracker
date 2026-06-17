# kaBluey — Time Tracker

A lightweight Windows time-tracking app that sits in your system tray, prompts you at regular
intervals, and optionally syncs your entries to your Microsoft 365 Outlook calendar.

---

## Download

kaBluey is distributed via the Microsoft Store (direct link — not publicly searchable).

> **Store link:** *(to be added after Store submission)*

---

## Features

- Regular prompts at configurable intervals (10 / 15 / 20 minutes)
- System tray — runs quietly in the background
- Daily log editor — view, add, edit, and delete time entries
- Daily progress banner showing hours logged vs your contracted hours
- Weekly report grouped by job and work type
- Microsoft 365 / Outlook calendar sync (optional)
- Calendar preview — tick today's Outlook events into your time log
- Outlook Tasks sync — keep your job list in sync (optional)
- 9 configurable work-type categories
- Private entries — marked sensitive in Outlook
- Dark mode support
- Local-first — all data stored on your device in plain-text files
- No telemetry, no ads, no external servers

---

## Documentation

| Document | Description |
|----------|-------------|
| [Configuration reference](docs/configuration.md) | All INI settings, CLI flags, hidden keys, log file format |
| [Changelog](docs/changelog.md) | Version history |
| [Privacy policy](docs/privacy-policy.html) | What data kaBluey stores and how |
| [M365 setup guide](docs/m365-setup.md) | How to set up Outlook calendar and Tasks sync |

---

## Releases

Signed releases are published in [`releases/`](releases/). Each release includes:

- `kaBluey.msix` — the installable package
- `SHA256SUMS.txt` — checksums
- `SHA256SUMS.txt.asc` — GPG signature (key: `1A16DDB2F5F54436`)

---

## Privacy

kaBluey has no servers and collects no telemetry. See the
[privacy policy](docs/privacy-policy.html) for full details.

Source code is available in the private repository for audit by authorised parties.

---

## Support

Report issues at the source repository's issue tracker, or email via the contact in the
privacy policy.

---

## License

kaBluey is free to use. See LICENSE for terms.
