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
$RepoName = "agent-skills"
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

function Write-Status($Kind, $Message) {
    switch ($Kind) {
        "step" { $prefix = "[step]"; $color = "Cyan" }
        "ok" { $prefix = "[ok]"; $color = "Green" }
        "warn" { $prefix = "[warn]"; $color = "Yellow" }
        "dry-run" { $prefix = "[dry-run]"; $color = "Magenta" }
        default { $prefix = "[info]"; $color = "Gray" }
    }

    Write-Host $prefix -ForegroundColor $color -NoNewline
    Write-Host " $Message"
}

function Write-Option($Number, $Name, $Path) {
    Write-Host "  " -NoNewline
    Write-Host "[$Number]" -ForegroundColor Yellow -NoNewline
    Write-Host " $Name" -NoNewline
    Write-Host "  $Path" -ForegroundColor DarkGray
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

function Backup-Existing($Path, $Timestamp, $BackupPath) {
    if (-not (Test-Path $Path)) {
        return $null
    }

    $backupPath = if ($BackupPath) { $BackupPath } else { "$Path.bak.$Timestamp" }
    if (-not $DryRun) {
        $backupParent = Split-Path -Parent $backupPath
        if ($backupParent) {
            New-Item -ItemType Directory -Force -Path $backupParent | Out-Null
        }
        Move-Item -LiteralPath $Path -Destination $backupPath -Force
    }

    return $backupPath
}

function Copy-PathWithBackup($Source, $Destination, $Timestamp, $BackupPath = $null) {
    $exists = Test-Path $Destination
    if ($exists) {
        if (-not (Confirm-Overwrite $Destination)) {
            Write-Status "warn" "skipped $Destination"
            return
        }
        $backupPath = Backup-Existing $Destination $Timestamp $BackupPath
    } else {
        $backupPath = $null
    }

    $verb = if ($exists) { "update" } else { "install" }
    $doneVerb = if ($exists) { "updated" } else { "installed" }
    $backupNote = if ($backupPath) { " (backup: $backupPath)" } else { "" }
    if ($DryRun) {
        Write-Status "dry-run" "would $verb $Destination$backupNote"
        return
    }

    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
    Write-Status "ok" "$doneVerb $Destination$backupNote"
}

function Move-LegacySkillBackups($TargetSkills, $BackupRoot) {
    if (-not (Test-Path $TargetSkills)) {
        return
    }

    Get-ChildItem -Path $TargetSkills -Directory | Where-Object {
        ($_.Name -match "^.+\.bak\.\d{14}$") -and
        (Test-Path (Join-Path $_.FullName "SKILL.md"))
    } | ForEach-Object {
        $destination = Join-Path $BackupRoot $_.Name
        if (Test-Path $destination) {
            Write-Status "warn" "legacy backup already exists, skipped $($_.FullName)"
            return
        }

        if ($DryRun) {
            Write-Status "dry-run" "would move legacy skill backup $($_.FullName) to $destination"
            return
        }

        New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
        Move-Item -LiteralPath $_.FullName -Destination $destination
        Write-Status "ok" "moved legacy skill backup $($_.FullName) to $destination"
    }
}

function Select-Target {
    if ($Target) {
        Assert-ValidTarget $Target
        return $Target
    }

    Write-Status "step" "Select install target"
    Write-Option "1" "Codex      " "~/.codex"
    Write-Option "2" "Claude Code" "~/.claude"
    Write-Option "3" "Common     " "~/.agents"
    Write-Option "4" "All        " "all targets"
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
    $sourceRoot = Get-ChildItem -Path $WorkDir -Directory | Where-Object {
        (Test-Path (Join-Path $_.FullName "AGENTS.md")) -and
        (Test-Path (Join-Path $_.FullName "skills")) -and
        (Test-Path (Join-Path $_.FullName "install.ps1"))
    } | Select-Object -First 1
    if (-not $sourceRoot) {
        throw "Unable to locate extracted source directory."
    }

    return $sourceRoot.FullName
}

function Install-ToTarget($SourceRoot, $Spec, $Timestamp) {
    Write-Status "step" "Installing to $($Spec.Name): $($Spec.Root)"

    $sourceRules = Join-Path $SourceRoot "AGENTS.md"
    $targetRules = Join-Path $Spec.Root $Spec.RulesFile
    Copy-PathWithBackup $sourceRules $targetRules $Timestamp

    $sourceSkills = Join-Path $SourceRoot "skills"
    $targetSkills = Join-Path $Spec.Root "skills"
    $skillBackupRoot = Join-Path $Spec.Root ".skill-backups"
    $skillBackupRoot = Join-Path $skillBackupRoot "skills"

    if (-not (Test-Path $sourceSkills)) {
        throw "Missing source skills directory: $sourceSkills"
    }

    Move-LegacySkillBackups $targetSkills $skillBackupRoot

    Get-ChildItem -Path $sourceSkills -Directory | ForEach-Object {
        $destination = Join-Path $targetSkills $_.Name
        $backupDestination = Join-Path $skillBackupRoot "$($_.Name).bak.$Timestamp"
        Copy-PathWithBackup $_.FullName $destination $Timestamp $backupDestination
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
    Write-Status "step" "Downloading $RepoOwner/$RepoName@$Ref"
    $sourceRoot = Expand-ArchiveFromGitHub $workDir
    Write-Status "ok" "source ready: $sourceRoot"
    $specs = Get-TargetSpecs $selectedTarget
    foreach ($spec in $specs) {
        Install-ToTarget $sourceRoot $spec $timestamp
    }
    Write-Status "ok" "Done."
} finally {
    if (Test-Path $workDir) {
        Remove-Item -LiteralPath $workDir -Recurse -Force
    }
}
