param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\.."))
)

$ErrorActionPreference = "Stop"
$agentDirectory = Join-Path $ProjectRoot ".github\agents"
$skillDirectory = Join-Path $ProjectRoot ".github\skills\roi-practice"

$agents = Get-ChildItem (Join-Path $agentDirectory "*.agent.md")
if ($agents.Count -ne 5) {
    throw "Expected 5 agent definitions, found $($agents.Count)"
}
foreach ($agent in $agents) {
    $text = Get-Content -Raw -Encoding UTF8 $agent.FullName
    if ($text -notmatch '(?s)^---\s*.*?name:\s*"[^"]+".*?description:\s*"[^"]+".*?---') {
        throw "Invalid agent frontmatter: $($agent.Name)"
    }
}

$skillPath = Join-Path $skillDirectory "SKILL.md"
$skill = Get-Content -Raw -Encoding UTF8 $skillPath
if ($skill -notmatch '(?s)^---\s*.*?name:\s*roi-practice.*?description:.*?---') {
    throw "Invalid SKILL.md frontmatter"
}

$references = Select-String -InputObject $skill -Pattern '\]\(\./references/([^\)]+)\)' -AllMatches |
    ForEach-Object { $_.Matches } |
    ForEach-Object { $_.Groups[1].Value }
foreach ($reference in $references) {
    if (-not (Test-Path (Join-Path "$skillDirectory\references" $reference))) {
        throw "Missing Skill reference: $reference"
    }
}

$scenarioCatalog = Get-Content -Raw -Encoding UTF8 (Join-Path $skillDirectory "references\scenario-catalog.json") | ConvertFrom-Json
$benchmarkCatalog = Get-Content -Raw -Encoding UTF8 (Join-Path $skillDirectory "references\benchmark-catalog.json") | ConvertFrom-Json
if ($scenarioCatalog.templates.Count -ne 18) {
    throw "Expected 18 practice templates, found $($scenarioCatalog.templates.Count)"
}
if ($benchmarkCatalog.benchmarks.Count -ne 6) {
    throw "Expected 6 benchmark scenarios, found $($benchmarkCatalog.benchmarks.Count)"
}

& (Join-Path $skillDirectory "scripts\validate-state.ps1") -ProjectRoot $ProjectRoot | Out-Null
Write-Output "Project validation passed: 5 agents, 18 practice templates, 6 benchmarks, valid learner state."