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
Copy-Item (Join-Path $ScriptDir 'AppxManifest.xml') $Layout
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
        $secPwd = Read-Host -Prompt "Enter PFX password for kaBluey-dev.pfx" -AsSecureString
    } else {
        $secPwd = ConvertTo-SecureString $CertPassword -AsPlainText -Force
    }

    # Remove any stale cert from the store
    Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq 'CN=Brendon Davis' -and $_.FriendlyName -eq 'kaBluey Dev Cert' } | Remove-Item -Force -ErrorAction SilentlyContinue

    $cert = New-SelfSignedCertificate `
        -Type Custom `
        -Subject 'CN=Brendon Davis' `
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
        $secPwd = Read-Host -Prompt "Enter PFX password" -AsSecureString
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

$hash = (Get-FileHash $destMsix -Algorithm SHA256).Hash.ToLower()
$sumsPath = Join-Path $OutputDir 'SHA256SUMS.txt'
"$hash  $MsixName" | Set-Content $sumsPath -Encoding UTF8NoBOM
Write-Host "  MSIX:       $destMsix"
Write-Host "  SHA256:     $hash"
Write-Host "  SHA256SUMS: $sumsPath"

Write-Host "`nBuild complete: $MsixName"
Write-Host "Run WACK: Start -> 'Windows App Certification Kit' -> 'Validate a Store app' -> browse to the .msix above"
