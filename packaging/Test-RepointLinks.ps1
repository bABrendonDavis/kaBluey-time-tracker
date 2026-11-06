#Requires -Version 5.1
<#
.SYNOPSIS
    Self-test for repoint_support_links.ps1 (no Windows SDK, no build needed).

.DESCRIPTION
    Builds a throw-away staging layout from the real kaBluey help page, NOTICES.txt and
    distribution.json (read-only copies), runs Invoke-SupportLinkRepoint, and checks:
      - distribution.json becomes the public channel/URL
      - no private-repository link remains in any staged text file
      - the replacement is word-bounded (kaBluey-time-tracker is left alone)
      - UTF-8 BOM state and LF / CRLF line endings are preserved byte for byte
      - the build fails when a private link survives, or distribution.json is missing
    Usage:  .\Test-RepointLinks.ps1 [-KaBlueyRoot ..\..\kaBluey]
#>
param([string]$KaBlueyRoot = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'repoint_support_links.ps1')

if ($KaBlueyRoot -eq '') { $KaBlueyRoot = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'kaBluey' }
$failures = 0
function Assert-True([bool]$Condition, [string]$Message) {
    if ($Condition) { Write-Host "  ok    $Message" }
    else { Write-Host "  FAIL  $Message" -ForegroundColor Red; $script:failures++ }
}
function New-Layout {
    $root = Join-Path ([System.IO.Path]::GetTempPath()) ("kb-repoint-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force (Join-Path $root '_internal\assets') | Out-Null
    return $root
}
function Copy-Real([string]$Layout) {
    Copy-Item (Join-Path $KaBlueyRoot 'assets\kabluey_help.html') (Join-Path $Layout '_internal\assets\')
    Copy-Item (Join-Path $KaBlueyRoot 'assets\distribution.json')  (Join-Path $Layout '_internal\assets\')
    Copy-Item (Join-Path $KaBlueyRoot 'NOTICES.txt') $Layout
}

Write-Host "Test 1: real kaBluey files"
$before = @{}
foreach ($f in 'assets\kabluey_help.html', 'assets\distribution.json', 'NOTICES.txt') {
    $before[$f] = [System.IO.File]::ReadAllBytes((Join-Path $KaBlueyRoot $f))
}
$layout = New-Layout
Copy-Real $layout
Invoke-SupportLinkRepoint -Layout $layout | Out-Null
$dist = Read-TextFileRaw (Join-Path $layout '_internal\assets\distribution.json')
Assert-True ($dist.Text -match '"channel":"public"') 'distribution.json channel is public'
Assert-True ($dist.Text.Contains("$($script:PublicRepoUrl)/issues")) 'distribution.json support_url is the public issues URL'
$help = Read-TextFileRaw (Join-Path $layout '_internal\assets\kabluey_help.html')
Assert-True (-not [regex]::IsMatch($help.Text, $script:PrivateRepoAnyPattern)) 'help page has no private-repository link'
Assert-True ($help.Text.Contains("$($script:PublicRepoUrl)/issues")) 'help page links the public issue tracker'
Assert-True (-not $help.Text.Contains('blob/main/SECURITY.md')) 'help page no longer links a non-existent public SECURITY.md'
Assert-True ($help.Text.Contains("href=`"$($script:PublicSupportUrl)`"")) 'help page contact links go to the public issue tracker'
$notices = Read-TextFileRaw (Join-Path $layout 'NOTICES.txt')
Assert-True (-not [regex]::IsMatch($notices.Text, $script:PrivateRepoAnyPattern)) 'NOTICES.txt has no private-repository link'
foreach ($f in 'assets\kabluey_help.html', 'assets\distribution.json', 'NOTICES.txt') {
    $now = [System.IO.File]::ReadAllBytes((Join-Path $KaBlueyRoot $f))
    Assert-True ((@(Compare-Object $before[$f] $now -SyncWindow 0)).Count -eq 0 -and $before[$f].Length -eq $now.Length) "source file unchanged: $f"
}
Remove-Item $layout -Recurse -Force

Write-Host "Test 2: BOM and line endings preserved; word-bounded replacement"
$layout = New-Layout
$assets = Join-Path $layout '_internal\assets'
$bom = [byte[]]@(0xEF, 0xBB, 0xBF)
$enc = New-Object System.Text.UTF8Encoding($false)
$helpText = "see https://github.com/bABrendonDavis/kaBluey/issues`r`nand https://github.com/bABrendonDavis/kaBluey-time-tracker/issues`r`nrepo https://github.com/bABrendonDavis/kaBluey."
[System.IO.File]::WriteAllBytes((Join-Path $assets 'kabluey_help.html'), [byte[]]($bom + $enc.GetBytes($helpText)))
[System.IO.File]::WriteAllBytes((Join-Path $layout 'NOTICES.txt'), $enc.GetBytes("a https://github.com/bABrendonDavis/kaBluey`nb"))
[System.IO.File]::WriteAllBytes((Join-Path $assets 'distribution.json'), [byte[]]($bom + $enc.GetBytes('{"channel": "internal"}')))
Invoke-SupportLinkRepoint -Layout $layout | Out-Null
$h = [System.IO.File]::ReadAllBytes((Join-Path $assets 'kabluey_help.html'))
Assert-True ($h[0] -eq 0xEF -and $h[1] -eq 0xBB -and $h[2] -eq 0xBF) 'help page keeps its BOM'
$hText = $enc.GetString($h, 3, $h.Length - 3)
Assert-True ($hText.Contains("`r`n") -and -not $hText.Replace("`r`n", '').Contains("`n")) 'help page keeps CRLF line endings'
Assert-True ($hText.Contains("kaBluey-time-tracker/issues`r`nand")) 'issues link re-pointed'
Assert-True (([regex]::Matches($hText, 'kaBluey-time-tracker-time-tracker')).Count -eq 0) 'already-public link not mangled'
Assert-True ($hText.EndsWith('kaBluey-time-tracker.')) 'bare repository URL re-pointed'
$n = [System.IO.File]::ReadAllBytes((Join-Path $layout 'NOTICES.txt'))
Assert-True (-not ($n[0] -eq 0xEF -and $n[1] -eq 0xBB)) 'NOTICES.txt stays BOM-less'
Assert-True ($enc.GetString($n).Contains("kaBluey-time-tracker`nb")) 'NOTICES.txt keeps LF and is re-pointed'
$d = [System.IO.File]::ReadAllBytes((Join-Path $assets 'distribution.json'))
Assert-True ($d[0] -eq 0xEF -and $d[1] -eq 0xBB -and $d[2] -eq 0xBF) 'distribution.json keeps its BOM state'
Remove-Item $layout -Recurse -Force

Write-Host "Test 2b: security link and case-insensitive URLs"
$layout = New-Layout
$assets = Join-Path $layout '_internal\assets'
$mixed = 'a https://github.com/bABrendonDavis/kaBluey/blob/main/SECURITY.md b https://GitHub.com/BABRENDONDAVIS/KABLUEY/issues c https://github.com/babrendondavis/kabluey. d https://github.com/bABrendonDavis/kaBluey-time-tracker/x'
[System.IO.File]::WriteAllText((Join-Path $assets 'kabluey_help.html'), $mixed)
[System.IO.File]::WriteAllText((Join-Path $layout 'NOTICES.txt'), 'n')
[System.IO.File]::WriteAllText((Join-Path $assets 'distribution.json'), '{}')
Invoke-SupportLinkRepoint -Layout $layout | Out-Null
$m = (Read-TextFileRaw (Join-Path $assets 'kabluey_help.html')).Text
Assert-True ($m -eq "a $($script:PublicSupportUrl) b $($script:PublicSupportUrl) c $($script:PublicRepoUrl). d $($script:PublicRepoUrl)/x") 'SECURITY.md link -> issues; mixed-case URLs re-pointed; public URL untouched'
Remove-Item $layout -Recurse -Force

Write-Host "Test 3: failure modes"
$layout = New-Layout
Copy-Real $layout
[System.IO.File]::WriteAllText((Join-Path $layout '_internal\assets\extra.txt'), "x github.com/bABrendonDavis/kaBluey/issues y")
$threw = $false
try { Invoke-SupportLinkRepoint -Layout $layout | Out-Null } catch { $threw = $_.Exception.Message -match 'Private repository link' }
Assert-True $threw 'a surviving private link fails the build'
Remove-Item $layout -Recurse -Force

$layout = New-Layout
Copy-Real $layout
Remove-Item (Join-Path $layout '_internal\assets\distribution.json')
$threw = $false
try { Invoke-SupportLinkRepoint -Layout $layout | Out-Null } catch { $threw = $_.Exception.Message -match 'distribution.json' }
Assert-True $threw 'a missing distribution.json fails the build'
Remove-Item $layout -Recurse -Force

if ($failures -gt 0) { Write-Host "`n$failures check(s) FAILED" -ForegroundColor Red; exit 1 }
Write-Host "`nAll checks passed."
