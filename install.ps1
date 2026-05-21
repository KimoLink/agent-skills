param(
    [string]$Target,
    [string]$Ref = "master",
    [switch]$Yes,
    [switch]$DryRun,
    [switch]$Version,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$RepoOwner = "KimoLink"
$RepoName = ".agents"
$ArchiveUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/$Ref.zip"
$TagArchiveUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/tags/$Ref.zip"

function Show-Help {
    @"
Install Kimo Agent Skill Pack.

Usage:
  powershell -ExecutionPolicy Bypass -File install.ps1 [options]
  irm https://raw.githubusercontent.com/$RepoOwner/$RepoName/master/install.ps1 | iex

Options:
  -Target codex|claude|agents|all  Install target. Omit for interactive selection.
  -Ref <ref>                       Git branch or tag to install from. Default: master.
  -Yes                             Accept overwrite prompts.
  -DryRun                          Print planned changes without writing files.
  -Version                         Print installer version.
  -Help                            Print this help.
"@
}

function Get-InstallerVersion {
    $versionFile = Join-Path $PSScriptRoot "VERSION"
    if (Test-Path $versionFile) {
        return (Get-Content -Path $versionFile -TotalCount 1).Trim()
    }
    return $Ref
}

function Assert-ValidTarget($Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    $validTargets = @("codex", "claude", "agents", "all")
    if ($validTargets -notcontains $Value) {
        throw "Invalid target: $Value. Expected one of: $($validTargets -join ', ')."
    }
}

function Confirm-Overwrite($Path) {
    if ($Yes) {
        return $true
    }

    $answer = Read-Host "Overwrite existing $Path ? [Y/n]"
    return [string]::IsNullOrWhiteSpace($answer) -or $answer -match "^(y|yes)$"
}

function Backup-Existing($Path, $Timestamp) {
    if (-not (Test-Path $Path)) {
        return
    }

    $backupPath = "$Path.bak.$Timestamp"
    if ($DryRun) {
        Write-Host "[dry-run] backup $Path -> $backupPath"
        return
    }

    Move-Item -LiteralPath $Path -Destination $backupPath -Force
    Write-Host "Backed up $Path -> $backupPath"
}

function Copy-PathWithBackup($Source, $Destination, $Timestamp) {
    if (Test-Path $Destination) {
        if (-not (Confirm-Overwrite $Destination)) {
            Write-Host "Skipped $Destination"
            return
        }
        Backup-Existing $Destination $Timestamp
    }

    if ($DryRun) {
        Write-Host "[dry-run] copy $Source -> $Destination"
        return
    }

    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
    Write-Host "Installed $Destination"
}

function Select-Target {
    if ($Target) {
        Assert-ValidTarget $Target
        return $Target
    }

    Write-Host "Select install target:"
    Write-Host "  1. Codex       ~/.codex"
    Write-Host "  2. Claude Code ~/.claude"
    Write-Host "  3. Common      ~/.agents"
    Write-Host "  4. All"
    $choice = Read-Host "Target [1-4]"

    switch ($choice) {
        "1" { return "codex" }
        "2" { return "claude" }
        "3" { return "agents" }
        "4" { return "all" }
        default { throw "Invalid target selection: $choice" }
    }
}

function Get-TargetSpecs($SelectedTarget) {
    $homeDir = [Environment]::GetFolderPath("UserProfile")
    $specs = @()

    if ($SelectedTarget -eq "codex" -or $SelectedTarget -eq "all") {
        $specs += @{
            Name = "Codex"
            Root = Join-Path $homeDir ".codex"
            RulesFile = "AGENTS.md"
        }
    }

    if ($SelectedTarget -eq "claude" -or $SelectedTarget -eq "all") {
        $specs += @{
            Name = "Claude Code"
            Root = Join-Path $homeDir ".claude"
            RulesFile = "CLAUDE.md"
        }
    }

    if ($SelectedTarget -eq "agents" -or $SelectedTarget -eq "all") {
        $specs += @{
            Name = "Common"
            Root = Join-Path $homeDir ".agents"
            RulesFile = "AGENTS.md"
        }
    }

    return $specs
}

function Expand-ArchiveFromGitHub($WorkDir) {
    $archivePath = Join-Path $WorkDir "agents.zip"
    try {
        Invoke-WebRequest -Uri $ArchiveUrl -OutFile $archivePath
    } catch {
        Invoke-WebRequest -Uri $TagArchiveUrl -OutFile $archivePath
    }

    Expand-Archive -LiteralPath $archivePath -DestinationPath $WorkDir -Force
    $sourceRoot = Get-ChildItem -Path $WorkDir -Directory | Where-Object { $_.Name -like "$RepoName-*" } | Select-Object -First 1
    if (-not $sourceRoot) {
        throw "Unable to locate extracted source directory."
    }

    return $sourceRoot.FullName
}

function Install-ToTarget($SourceRoot, $Spec, $Timestamp) {
    Write-Host "Installing to $($Spec.Name): $($Spec.Root)"

    $sourceRules = Join-Path $SourceRoot "AGENTS.md"
    $targetRules = Join-Path $Spec.Root $Spec.RulesFile
    Copy-PathWithBackup $sourceRules $targetRules $Timestamp

    $sourceSkills = Join-Path $SourceRoot "skills"
    $targetSkills = Join-Path $Spec.Root "skills"

    if (-not (Test-Path $sourceSkills)) {
        throw "Missing source skills directory: $sourceSkills"
    }

    Get-ChildItem -Path $sourceSkills -Directory | ForEach-Object {
        $destination = Join-Path $targetSkills $_.Name
        Copy-PathWithBackup $_.FullName $destination $Timestamp
    }
}

if ($Help) {
    Show-Help
    exit 0
}

if ($Version) {
    Write-Host (Get-InstallerVersion)
    exit 0
}

$selectedTarget = Select-Target
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$workDirName = "agents-install-$timestamp-$([System.Guid]::NewGuid().ToString('N'))"
$workDir = Join-Path ([System.IO.Path]::GetTempPath()) $workDirName

New-Item -ItemType Directory -Force -Path $workDir | Out-Null

try {
    $sourceRoot = Expand-ArchiveFromGitHub $workDir
    $specs = Get-TargetSpecs $selectedTarget
    foreach ($spec in $specs) {
        Install-ToTarget $sourceRoot $spec $timestamp
    }
    Write-Host "Done."
} finally {
    if (Test-Path $workDir) {
        Remove-Item -LiteralPath $workDir -Recurse -Force
    }
}
