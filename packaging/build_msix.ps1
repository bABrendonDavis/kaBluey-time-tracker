#Requires -Version 5.1
<#
.SYNOPSIS
    Build, sign, and output the kaBluey MSIX package for WACK / Store submission.

.DESCRIPTION
    Reusable across build iterations. Run from the kaBluey-time-tracker\packaging\
    directory, or pass explicit paths. Update $BUILD to match version.py before each run.

.PARAMETER Build
    Build number (default 41). Must match version.py BUILD value.

.PARAMETER Version
    App version string (default 0.7.2). Must match version.py VERSION value.

.PARAMETER CertPassword
    Password for the self-signed dev certificate PFX. If omitted, prompts securely.

.PARAMETER SkipCertCreate
    If kaBluey-dev.pfx already exists and is valid, skip certificate creation.

.PARAMETER OutputDir
    Where to copy the final MSIX and SHA256SUMS.txt. Defaults to ..\releases\v{Version}\

.EXAMPLE
    .\build_msix.ps1
    .\build_msix.ps1 -Build 42 -Version 0.7.3
    .\build_msix.ps1 -SkipCertCreate -CertPassword "mypassword"
#>
param(
    [int]   $Build        = 41,
    [string]$Version      = '0.7.2',
    [string]$CertPassword = '',
    [switch]$SkipCertCreate,
    [string]$OutputDir    = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# UTF8NoBOM is only a valid -Encoding literal on PowerShell 6+; on 5.1 (the
# version this script targets) it throws. Write via .NET directly so behaviour
# is identical (no BOM) on every PowerShell version.
function Set-ContentUtf8NoBom([string]$Path, [string]$Content) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

# GUI password popup so this script can be driven from a non-interactive
# console (e.g. launched by an agent/automation) without blocking on stdin:
# Read-Host would hang forever if nothing is attached to the console's input.
# A WinForms dialog runs in its own window regardless of how the process was
# started, mirroring the gpg-agent pinentry popup used for release signing.
function Read-PfxPasswordGui([string]$Prompt) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'kaBluey MSIX Signing'
    $form.Size = New-Object System.Drawing.Size(420, 160)
    $form.StartPosition = 'CenterScreen'
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Prompt
    $label.SetBounds(10, 15, 390, 20)
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.SetBounds(10, 40, 380, 24)
    $textBox.UseSystemPasswordChar = $true
    $form.Controls.Add($textBox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = 'OK'
    $okButton.SetBounds(230, 80, 75, 28)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($okButton)
    $form.AcceptButton = $okButton

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = 'Cancel'
    $cancelButton.SetBounds(315, 80, 75, 28)
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($cancelButton)
    $form.CancelButton = $cancelButton

    $form.Add_Shown({ $textBox.Focus() })
    $result = $form.ShowDialog()

    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        throw 'PFX password entry cancelled.'
    }
    # Built via .NET directly (not the ConvertTo-SecureString cmdlet) — in this
    # environment Microsoft.PowerShell.Security fails to autoload, which makes
    # ConvertTo-SecureString throw before the password is even checked.
    $secure = New-Object System.Security.SecureString
    foreach ($ch in $textBox.Text.ToCharArray()) { $secure.AppendChar($ch) }
    $secure.MakeReadOnly()
    return $secure
}

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
$ScriptDir   = $PSScriptRoot
$RepoRoot    = Split-Path $ScriptDir -Parent           # kaBluey-time-tracker\
$KaBlueyRoot = Join-Path (Split-Path $RepoRoot -Parent) 'kaBluey'  # ..\kaBluey\
$DistOnedir  = Join-Path $KaBlueyRoot "dist\kaBluey"   # onedir bundle
$NoticesFile = Join-Path $KaBlueyRoot "NOTICES.txt"
$MsixName    = "kaBluey_${Version}.${Build}_x64.msix"
$Layout      = Join-Path $ScriptDir "PackageLayout"
$MsixOut     = Join-Path $ScriptDir $MsixName
$PfxPath     = Join-Path $ScriptDir "kaBluey-dev.pfx"
$CerPath     = Join-Path $ScriptDir "kaBluey-dev.cer"

if ($OutputDir -eq '') {
    $OutputDir = Join-Path $RepoRoot "releases\v$Version"
}

# ---------------------------------------------------------------------------
# Locate Windows SDK tools
# ---------------------------------------------------------------------------
function Find-SdkTool([string]$Name) {
    $sdkRoot = 'C:\Program Files (x86)\Windows Kits\10\bin'
    $found = Get-ChildItem $sdkRoot -Recurse -Filter $Name -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match 'x64' } |
        Sort-Object { [version]($_.FullName -replace '.*\\(\d+\.\d+\.\d+\.\d+)\\.*','$1') } |
        Select-Object -Last 1
    if (-not $found) { throw "Cannot find $Name in Windows SDK at $sdkRoot" }
    return $found.FullName
}

$makeappx = Find-SdkTool 'makeappx.exe'
$signtool = Find-SdkTool 'signtool.exe'
Write-Host "makeappx: $makeappx"
Write-Host "signtool: $signtool"

# ---------------------------------------------------------------------------
# Validate source dist bundle
# ---------------------------------------------------------------------------
if (-not (Test-Path $DistOnedir)) {
    throw "Onedir bundle not found: $DistOnedir`nRun: pyinstaller kabluey.spec --clean -y"
}
$exeInBundle = Join-Path $DistOnedir 'kaBluey.exe'
if (-not (Test-Path $exeInBundle)) {
    throw "kaBluey.exe not found inside onedir bundle: $exeInBundle"
}

# ---------------------------------------------------------------------------
# Build package layout
# ---------------------------------------------------------------------------
Write-Host "`n[1/5] Building package layout..."
if (Test-Path $Layout) { Remove-Item $Layout -Recurse -Force }
New-Item -ItemType Directory -Force $Layout | Out-Null

# App files
Write-Host "  Copying onedir bundle..."
robocopy $DistOnedir $Layout /E /NP /NFL /NDL /NJH /NJS | Out-Null

# Manifest + assets
# Copy manifest then rewrite the Version attribute to Store-compliant {Version}.0 format.
# Microsoft Store requires the 4th component (revision) to be 0.
# The source AppxManifest.xml may carry any version string; the build always enforces X.Y.Z.0.
$LayoutManifest = Join-Path $Layout 'AppxManifest.xml'
Copy-Item (Join-Path $ScriptDir 'AppxManifest.xml') $LayoutManifest
$StoreVersion   = "$Version.0"
$ManifestXml    = Get-Content $LayoutManifest -Raw
$ManifestXml    = $ManifestXml -replace '(?<=<Identity[^>]*\sVersion=")[^"]*(?=")', $StoreVersion
Set-ContentUtf8NoBom $LayoutManifest $ManifestXml
Write-Host "  Manifest version set to $StoreVersion (Store revision-zero requirement)"
Copy-Item (Join-Path $ScriptDir 'Assets') (Join-Path $Layout 'Assets') -Recurse

# NOTICES.txt
if (Test-Path $NoticesFile) {
    Copy-Item $NoticesFile $Layout
    Write-Host "  NOTICES.txt included"
} else {
    Write-Warning "NOTICES.txt not found at $NoticesFile — package will not include open-source attribution"
}

Write-Host "  Layout complete: $((Get-ChildItem $Layout -Recurse -File).Count) files"

# ---------------------------------------------------------------------------
# Create self-signed dev certificate (skip if -SkipCertCreate and PFX exists)
# ---------------------------------------------------------------------------
if (-not $SkipCertCreate -or -not (Test-Path $PfxPath)) {
    Write-Host "`n[2/5] Creating self-signed dev certificate..."
    if ($CertPassword -eq '') {
        $secPwd = Read-PfxPasswordGui "Enter PFX password for kaBluey-dev.pfx"
    } else {
        $secPwd = ConvertTo-SecureString $CertPassword -AsPlainText -Force
    }

    # Remove any stale cert from the store
    Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq 'CN=5CF4127A-A18A-4763-908E-1A59A64DC58D' -and $_.FriendlyName -eq 'kaBluey Dev Cert' } | Remove-Item -Force -ErrorAction SilentlyContinue

    $cert = New-SelfSignedCertificate `
        -Type Custom `
        -Subject 'CN=5CF4127A-A18A-4763-908E-1A59A64DC58D' `
        -KeyUsage DigitalSignature `
        -FriendlyName 'kaBluey Dev Cert' `
        -CertStoreLocation 'Cert:\CurrentUser\My' `
        -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3', '2.5.29.19={text}')

    Export-PfxCertificate -Cert $cert -FilePath $PfxPath -Password $secPwd | Out-Null
    Export-Certificate    -Cert $cert -FilePath $CerPath -Type CERT | Out-Null
    Write-Host "  PFX: $PfxPath"
    Write-Host "  CER: $CerPath"
    Write-Host ""
    Write-Host "  *** To install the package, trust the cert first: ***"
    Write-Host "  Import-Certificate -FilePath '$CerPath' -CertStoreLocation 'Cert:\LocalMachine\TrustedPeople'"
    Write-Host ""
} else {
    Write-Host "`n[2/5] Reusing existing dev certificate: $PfxPath"
    if ($CertPassword -eq '') {
        $secPwd = Read-PfxPasswordGui "Enter PFX password for kaBluey-dev.pfx"
    } else {
        $secPwd = ConvertTo-SecureString $CertPassword -AsPlainText -Force
    }
}

# ---------------------------------------------------------------------------
# Pack MSIX
# ---------------------------------------------------------------------------
Write-Host "`n[3/5] Packing MSIX..."
if (Test-Path $MsixOut) { Remove-Item $MsixOut -Force }
& $makeappx pack /d $Layout /p $MsixOut /nv /o
if ($LASTEXITCODE -ne 0) { throw "makeappx failed (exit $LASTEXITCODE)" }
Write-Host "  Packed: $MsixOut"

# ---------------------------------------------------------------------------
# Sign MSIX
# ---------------------------------------------------------------------------
Write-Host "`n[4/5] Signing MSIX..."
# Convert SecureString to plain for signtool /p parameter
$bstr  = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPwd)
$plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

& $signtool sign /fd SHA256 /f $PfxPath /p $plain /tr "http://timestamp.digicert.com" /td SHA256 $MsixOut
if ($LASTEXITCODE -ne 0) { throw "signtool failed (exit $LASTEXITCODE)" }
Write-Host "  Signed: $MsixOut"

# ---------------------------------------------------------------------------
# Output to releases/
# ---------------------------------------------------------------------------
Write-Host "`n[5/5] Copying to release folder..."
New-Item -ItemType Directory -Force $OutputDir | Out-Null
$destMsix = Join-Path $OutputDir $MsixName
Copy-Item $MsixOut $destMsix -Force

# Get-FileHash (Microsoft.PowerShell.Utility) also fails to autoload in this
# environment — compute the SHA256 directly via .NET instead.
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$fileStream = [System.IO.File]::OpenRead($destMsix)
try {
    $hashBytes = $sha256.ComputeHash($fileStream)
} finally {
    $fileStream.Close()
}
$hash = ([System.BitConverter]::ToString($hashBytes) -replace '-', '').ToLower()
$sumsPath = Join-Path $OutputDir 'SHA256SUMS.txt'
Set-ContentUtf8NoBom $sumsPath "$hash  $MsixName`n"
Write-Host "  MSIX:       $destMsix"
Write-Host "  SHA256:     $hash"
Write-Host "  SHA256SUMS: $sumsPath"

Write-Host "`nBuild complete: $MsixName"
Write-Host "Run WACK: Start -> 'Windows App Certification Kit' -> 'Validate a Store app' -> browse to the .msix above"
