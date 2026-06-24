# Microsoft 365 Setup Guide for kaBluey

This guide explains how to connect kaBluey to your Microsoft 365 account so it can sync time
entries to your Outlook calendar and optionally sync jobs from Outlook Tasks.

> **Lite mode note:** If you are using kaBluey on a personal device (not joined to an Entra ID /
> Azure AD domain), the app runs in **Lite mode**.  All core time-tracking features work without
> any M365 connection.  This guide is only needed if you want calendar sync.

---

## What kaBluey requests access to

kaBluey requests the minimum OAuth scopes needed:

| Scope | When requested | Purpose |
|-------|---------------|---------|
| `Calendars.ReadWrite` | When you first click **Sync** | Upload time entries as calendar events; read today's calendar for the preview panel |
| `Tasks.ReadWrite` | Only if you enable Tasks sync in Settings | Read and create Outlook Tasks for your job list |

kaBluey never requests access to your email, contacts, files, or any other Microsoft 365 resource.

---

## Sign-in flow

kaBluey uses the **Microsoft device-code flow** (no pop-up browser window):

1. Click **Sync** in the kaBluey editor, or **Connect** in Settings → Microsoft 365.
2. A small dialog appears with a code (e.g. `ABCD-1234`) and the URL `https://microsoft.com/devicelogin`.
3. Open that URL in any browser, enter the code, and sign in with your Microsoft account.
4. Return to kaBluey — it detects the completed sign-in automatically.

Your password is never entered into kaBluey.  Only Microsoft's own sign-in pages handle
your credentials.  The resulting token is stored in **Windows Credential Manager** under the
entry name `kaBluey-m365`.

---

## For enterprise users: Azure AD app registration

If your organisation's IT policy restricts third-party app sign-ins (tenant-level "user consent"
is disabled), you may need your IT administrator to register kaBluey as an approved application
in your Azure AD tenant.

### Option A — Use the built-in kaBluey app (default, no setup required)

kaBluey includes a registered multi-tenant Microsoft Entra ID (Azure AD) application.
Most personal Microsoft accounts and business tenants allow sign-in with no IT admin action.
Click **Connect** in Settings → Microsoft 365, follow the device-code prompt, and you are done.

### Option B — Register your own app (IT admin required)

If your tenant restricts third-party app consent, an admin can register a dedicated app:

1. Sign in to the [Azure Portal](https://portal.azure.com) as a Global Administrator or
   Application Administrator.
2. Go to **Azure Active Directory → App registrations → New registration**.
3. Fill in the form:
   - **Name:** `kaBluey` (or any name your organisation prefers)
   - **Supported account types:** *Accounts in this organizational directory only* (single-tenant)
     — or *Accounts in any organizational directory* if you support multiple tenants
   - **Redirect URI:** leave blank (device-code flow does not use a redirect URI)
4. Click **Register**.  Note the **Application (client) ID** shown on the Overview page.
5. Go to **API permissions → Add a permission → Microsoft Graph → Delegated permissions**.
   Add: `Calendars.ReadWrite` and (if using Tasks sync) `Tasks.ReadWrite`.
6. Click **Grant admin consent** so users are not prompted to individually consent.
7. (Optional) Under **Authentication**, enable **Allow public client flows** → Yes.  This is
   required for the device-code flow used by kaBluey.
8. Note the **Directory (tenant) ID** from the Overview page.

Then configure kaBluey to use your registration:

**Option 1 — via the Settings dialog (recommended):**

1. Open kaBluey → Settings → Microsoft 365 → Advanced.
2. Enter your **Application (client) ID** in the *Enterprise App ID* field.
3. Enter your **Directory (tenant) ID** in the *Directory ID* field (or leave blank to allow any tenant).
4. Click **Save** and restart kaBluey.

**Option 2 — via INI file:**

1. Open `kabluey.ini` (in your `Documents\kaBluey\` folder).
2. Add the following keys under `[settings]`:

   ```ini
   m365_override_client_id = <your Application (client) ID>
   m365_override_tenant_id = <your Directory (tenant) ID>
   ```

3. Save the file and restart kaBluey.

---

## Disconnecting

To disconnect kaBluey from Microsoft 365:

**Within the app:** Settings → Microsoft 365 tab → **Disconnect M365**.

**Manually:**
- Open **Windows Credential Manager** (search in Start menu).
- Under *Windows Credentials*, find `kaBluey-m365` and delete it.
- Also delete any `kaBluey-m365-*.json` files in your `Documents\kaBluey\` folder
  (these are fallback token cache files, only present if file-based caching is enabled).

**Revoking access from Microsoft's side:**
- Visit [myapps.microsoft.com](https://myapps.microsoft.com).
- Find **kaBluey** → **Remove access**.
- This revokes the token even if the local credential was not deleted.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| "AADSTS50020: User account from identity provider does not exist in tenant" | Signed in with personal MSA into a work-only tenant | Use your work account, or switch to multi-tenant registration |
| Sign-in dialog never confirms | Network blocks `login.microsoftonline.com` | Check firewall / proxy settings |
| "Insufficient privileges" after sign-in | Scopes were not admin-consented | Ask your IT admin to grant admin consent for the app registration |
| Calendar events not appearing | Calendar sync is off | Settings → Microsoft 365 → enable calendar sync, then Sync |
| Token expired after leaving device offline for a long time | Access tokens expire; refresh token may have expired | Disconnect and reconnect via Settings → Microsoft 365 |

---

*kaBluey uses MSAL (Microsoft Authentication Library) for all authentication.
No credentials are stored by kaBluey itself.*
