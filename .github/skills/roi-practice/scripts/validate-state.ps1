param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")),
    [switch]$StopCheck
)

$ErrorActionPreference = "Stop"
$profilePath = Join-Path $ProjectRoot ".roi-trainer\profile.json"
$activeSessionPath = Join-Path $ProjectRoot ".roi-trainer\active-session.json"

if (-not (Test-Path $profilePath)) {
    throw "Learner profile not found: $profilePath"
}

$profile = Get-Content -Raw -Encoding UTF8 $profilePath | ConvertFrom-Json
$requiredCompetencies = @(
    "businessOutcome",
    "roiAndTco",
    "assumptionsAndMeasurement",
    "riskAndGovernance",
    "industryTransformation",
    "executiveRecommendation"
)

if ($profile.schemaVersion -ne 1) {
    throw "Unsupported profile schema version: $($profile.schemaVersion)"
}

foreach ($competency in $requiredCompetencies) {
    if (-not $profile.competencies.PSObject.Properties[$competency]) {
        throw "Missing competency: $competency"
    }
}

if (-not $profile.nextFocus.competency -or -not $profile.nextFocus.behavior) {
    throw "nextFocus must contain competency and behavior"
}

if ($StopCheck -and (Test-Path $activeSessionPath)) {
    throw "An active practice session has not been completed: $activeSessionPath"
}

Write-Output "ROI trainer state is valid. Sessions: $($profile.sessionCount); Next focus: $($profile.nextFocus.competency)"