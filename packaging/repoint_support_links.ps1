#Requires -Version 5.1
<#
.SYNOPSIS
    Point the public MSIX's support links at the PUBLIC repository (staged copy only).

.DESCRIPTION
    The kaBluey source tree ships with links to the private repository (internal users have
    access). The public Microsoft Store / GitHub release package must instead point at the
    public kaBluey-time-tracker repository. This is done at MSIX build time, on the STAGED
    layout only - the kaBluey working tree is never modified:

      1. assets\distribution.json            -> {"channel":"public","support_url":<public issues>}
      2. staged assets\kabluey_help.html and NOTICES.txt:
           https://github.com/bABrendonDavis/kaBluey/blob/<branch>/SECURITY.md -> <public repo>/issues
              (the public repository has no SECURITY.md; the issue tracker is the contact page)
           https://github.com/bABrendonDavis/kaBluey/issues   -> <public repo>/issues
           https://github.com/bABrendonDavis/kaBluey           -> <public repo>
         (word-bounded: a following "-" or letter/digit means a different repository name)
      3. The build FAILS if any staged text file still refers to the private repository.

    Files are rewritten as raw bytes: the existing UTF-8 BOM state and LF/CRLF line endings are
    preserved exactly.

    Dot-source this file and call Invoke-SupportLinkRepoint -Layout <staging folder>.
#>

Set-StrictMode -Version Latest

$script:PublicRepoUrl      = 'https://github.com/bABrendonDavis/kaBluey-time-tracker'
$script:PublicSupportUrl   = "$($script:PublicRepoUrl)/issues"
# The private repository, as an exact URL not followed by a name character.
# GitHub URLs are case-insensitive, so every pattern is too.
$script:PrivateSecurityPattern = '(?i)https://github\.com/bABrendonDavis/kaBluey/blob/[^/\s"''<>)]+/SECURITY\.md'
$script:PrivateRepoUrlPattern = '(?i)https://github\.com/bABrendonDavis/kaBluey(?![A-Za-z0-9_-])'
# Any reference at all (with or without scheme) - used by the final guard.
$script:PrivateRepoAnyPattern = '(?i)github\.com/bABrendonDavis/kaBluey(?![A-Za-z0-9_-])'
$script:TextExtensions = @('.html', '.htm', '.txt', '.json', '.md', '.xml', '.ini', '.cfg', '.csv',
                           '.toml', '.yml', '.yaml', '.css', '.js', '.svg', '.manifest', '.rst')

function Read-TextFileRaw([string]$Path) {
    $bytes  = [System.IO.File]::ReadAllBytes($Path)
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    $offset = if ($hasBom) { 3 } else { 0 }
    $text   = [System.Text.Encoding]::UTF8.GetString($bytes, $offset, $bytes.Length - $offset)
    return @{ Text = $text; HasBom = $hasBom }
}

function Write-TextFileRaw([string]$Path, [string]$Text, [bool]$HasBom) {
    $body = (New-Object System.Text.UTF8Encoding($false)).GetBytes($Text)
    if ($HasBom) {
        $bytes = [byte[]](@(0xEF, 0xBB, 0xBF) + $body)
    } else {
        $bytes = $body
    }
    [System.IO.File]::WriteAllBytes($Path, $bytes)
}

function Find-StagedFile([string]$Layout, [string]$Name) {
    return @(Get-ChildItem -Path $Layout -Recurse -File -Filter $Name -ErrorAction SilentlyContinue)
}

function Invoke-SupportLinkRepoint {
    param([Parameter(Mandatory = $true)][string]$Layout)

    if (-not (Test-Path $Layout)) { throw "Staging layout not found: $Layout" }
    Write-Host "  Re-pointing support links for the public package (staged copy only)..."
    $summary = @()

    # 1. distribution.json - must exist exactly once, or the app would show the private link.
    $dist = @(Find-StagedFile $Layout 'distribution.json')
    if ($dist.Count -ne 1) {
        throw "Expected exactly one staged distribution.json, found $($dist.Count). " +
              "Rebuild the kaBluey onedir bundle from a version that ships assets\distribution.json."
    }
    $distFile = Read-TextFileRaw $dist[0].FullName
    $json = "{`"channel`":`"public`",`"support_url`":`"$($script:PublicSupportUrl)`"}`n"
    Write-TextFileRaw $dist[0].FullName $json $distFile.HasBom
    $summary += "  distribution.json -> channel=public, support_url=$($script:PublicSupportUrl)"

    # 2. help page and NOTICES: deterministic URL replacement.
    $targets = @(Find-StagedFile $Layout 'kabluey_help.html') + @(Find-StagedFile $Layout 'NOTICES.txt')
    if ($targets.Count -lt 2) {
        throw "Expected the staged help page and NOTICES.txt, found $($targets.Count) of 2."
    }
    foreach ($file in $targets) {
        $raw   = Read-TextFileRaw $file.FullName
        $text  = $raw.Text
        $nSecurity = [regex]::Matches($text, $script:PrivateSecurityPattern).Count
        $text  = [regex]::Replace($text, $script:PrivateSecurityPattern, $script:PublicSupportUrl)
        $issuesPattern = $script:PrivateRepoUrlPattern + '/issues'
        $nIssues = [regex]::Matches($text, $issuesPattern).Count
        $text  = [regex]::Replace($text, $issuesPattern, "$($script:PublicRepoUrl)/issues")
        $nRepo = [regex]::Matches($text, $script:PrivateRepoUrlPattern).Count
        $text  = [regex]::Replace($text, $script:PrivateRepoUrlPattern, $script:PublicRepoUrl)
        if ($nSecurity + $nIssues + $nRepo -gt 0) {
            Write-TextFileRaw $file.FullName $text $raw.HasBom
        }
        $summary += "  $($file.Name): $nSecurity security link(s), $nIssues issues link(s), $nRepo repository link(s) re-pointed"
    }

    # 3. Guard: no staged text file may still mention the private repository.
    $leaks = @()
    foreach ($file in (Get-ChildItem -Path $Layout -Recurse -File)) {
        if ($script:TextExtensions -notcontains $file.Extension.ToLowerInvariant()) { continue }
        $text = (Read-TextFileRaw $file.FullName).Text
        if ([regex]::IsMatch($text, $script:PrivateRepoAnyPattern)) {
            $leaks += $file.FullName.Substring($Layout.Length).TrimStart('\')
        }
    }
    foreach ($line in $summary) { Write-Host $line }
    if ($leaks.Count -gt 0) {
        throw "Private repository link(s) remain in the staged package: $($leaks -join ', ')"
    }
    Write-Host "  No private-repository links remain in the staged package."
    return $summary
}
