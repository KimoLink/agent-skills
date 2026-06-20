$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$installScript = Get-Content -Raw -Path (Join-Path $repoRoot "install.ps1")
$mainMarker = "if (`$Help) {"
$mainStart = $installScript.IndexOf($mainMarker)
if ($mainStart -lt 0) {
    throw "Unable to locate installer main block."
}
$prefix = $installScript.Substring(0, $mainStart)
. ([scriptblock]::Create($prefix))

function Assert-True($Condition, $Message) {
    if (-not $Condition) {
        throw $Message
    }
}

$traeSpecs = @(Get-TargetSpecs "trae")
Assert-True ($traeSpecs.Count -eq 1) "trae target should resolve to one install spec"
Assert-True ($traeSpecs[0].Name -eq "Trae") "trae target name should be Trae"
Assert-True ($traeSpecs[0].Root.EndsWith(".trae")) "trae target root should be ~/.trae"
Assert-True ($traeSpecs[0].RulesFile -eq "user_rules.md") "trae target should install user_rules.md"

$allSpecs = @(Get-TargetSpecs "all")
$traeInAll = @($allSpecs | Where-Object { $_.Name -eq "Trae" })
Assert-True ($traeInAll.Count -eq 1) "all target should include Trae"

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "agent-skills-backup-test-$([System.Guid]::NewGuid().ToString('N'))"
try {
    $sourceRoot = Join-Path $tempRoot "source"
    $sourceSkill = Join-Path $sourceRoot "skills\sample-skill"
    $targetSkill = Join-Path $tempRoot "target\skills\sample-skill"
    $legacyBackup = Join-Path $tempRoot "target\skills\sample-skill.bak.20260101010101"
    New-Item -ItemType Directory -Force -Path $sourceSkill | Out-Null
    New-Item -ItemType Directory -Force -Path $targetSkill | Out-Null
    New-Item -ItemType Directory -Force -Path $legacyBackup | Out-Null
    Set-Content -Path (Join-Path $sourceRoot "AGENTS.md") -Value "new rules"
    Set-Content -Path (Join-Path $sourceSkill "SKILL.md") -Value "new skill"
    Set-Content -Path (Join-Path $tempRoot "target\AGENTS.md") -Value "old rules"
    Set-Content -Path (Join-Path $targetSkill "SKILL.md") -Value "old skill"
    Set-Content -Path (Join-Path $legacyBackup "SKILL.md") -Value "legacy backup skill"

    $script:Yes = $true
    $script:DryRun = $false
    $timestamp = "20260601123456"
    $spec = @{
        Name = "Test"
        Root = Join-Path $tempRoot "target"
        RulesFile = "AGENTS.md"
    }
    Install-ToTarget $sourceRoot $spec $timestamp

    $backupRoot = Join-Path $tempRoot "target\.skill-backups\skills"
    $backupSkill = Join-Path $backupRoot "sample-skill.bak.$timestamp"
    $migratedLegacyBackup = Join-Path $backupRoot "sample-skill.bak.20260101010101"
    $rulesBackup = Join-Path $tempRoot "target\AGENTS.md.bak.$timestamp"

    Assert-True (Test-Path (Join-Path $targetSkill "SKILL.md")) "updated skill was not installed"
    Assert-True (Test-Path $rulesBackup) "rules backup should remain next to the rules file"
    Assert-True (Test-Path (Join-Path $backupSkill "SKILL.md")) "old skill was not moved to backup directory"
    Assert-True (-not (Test-Path (Join-Path $tempRoot "target\skills\sample-skill.bak.$timestamp"))) "backup remained under skills directory"
    Assert-True (Test-Path (Join-Path $migratedLegacyBackup "SKILL.md")) "legacy skill backup was not migrated"
    Assert-True (-not (Test-Path $legacyBackup)) "legacy skill backup remained under skills directory"

    Write-Host "install-backup.Tests.ps1 passed"
} finally {
    if (Test-Path $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
