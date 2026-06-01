$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$reviewRoot = Join-Path $repoRoot "skills\review-engineering"
$stackRoot = Join-Path $reviewRoot "stacks"

$stacks = @(
    "dotnet",
    "nest",
    "nuxt",
    "qt",
    "rust",
    "unity",
    "unreal"
)

function Assert-True($Condition, $Message) {
    if (-not $Condition) {
        throw $Message
    }
}

foreach ($stack in $stacks) {
    $entryPath = Join-Path $repoRoot "skills\review-$stack\SKILL.md"
    $agentPath = Join-Path $repoRoot "skills\review-$stack\agents\openai.yaml"
    $stackPath = Join-Path $stackRoot "$stack.md"
    $entryContent = Get-Content -Raw -Path $entryPath
    $agentContent = Get-Content -Raw -Path $agentPath
    $entryLines = (Get-Content -Path $entryPath | Measure-Object -Line).Lines

    Assert-True (Test-Path $stackPath) "missing stack checklist: $stackPath"
    Assert-True ($entryLines -le 45) "review-$stack entry is too large: $entryLines lines"
    Assert-True ($entryContent -match "review-engineering/stacks/$stack\.md") "review-$stack does not reference its stack checklist"
    Assert-True ($entryContent -match "review-engineering") "review-$stack does not reference review-engineering"
    Assert-True ($entryContent -match "docs/reviews/") "review-$stack does not preserve report output rule"
    Assert-True ($agentContent -match "review-engineering/stacks/$stack\.md") "review-$stack OpenAI prompt does not reference its stack checklist"
}

$engineeringContent = Get-Content -Raw -Path (Join-Path $reviewRoot "SKILL.md")
Assert-True ($engineeringContent -match "stacks/") "review-engineering does not document stack checklist loading"

Write-Host "review-skill-structure.Tests.ps1 passed"
