param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")),
    [string]$ActiveSessionPath
)

$ErrorActionPreference = "Stop"
$competencyNames = @(
    "businessOutcome",
    "roiAndTco",
    "assumptionsAndMeasurement",
    "riskAndGovernance",
    "industryTransformation",
    "executiveRecommendation"
)

if (-not $ActiveSessionPath) {
    $ActiveSessionPath = Join-Path $ProjectRoot ".roi-trainer\active-session.json"
}

$profilePath = Join-Path $ProjectRoot ".roi-trainer\profile.json"
$sessionsDirectory = Join-Path $ProjectRoot ".roi-trainer\sessions"
$exportsDirectory = Join-Path $ProjectRoot ".roi-trainer\exports"
$progressPath = Join-Path $exportsDirectory "progress.csv"

if (-not (Test-Path $ActiveSessionPath)) {
    throw "Active session not found: $ActiveSessionPath"
}
if (-not (Test-Path $profilePath)) {
    throw "Learner profile not found: $profilePath"
}

$session = Get-Content -Raw -Encoding UTF8 $ActiveSessionPath | ConvertFrom-Json
$profile = Get-Content -Raw -Encoding UTF8 $profilePath | ConvertFrom-Json

foreach ($property in @("sessionId", "startedAt", "completedAt", "mode", "scenario", "transcript", "selfReflection", "evaluation", "reflection")) {
    if (-not $session.PSObject.Properties[$property]) {
        throw "Session is missing required property: $property"
    }
}

if ($session.mode -notin @("practice", "benchmark", "quick")) {
    throw "Unsupported session mode: $($session.mode)"
}
if ($session.transcript.Count -lt 1) {
    throw "Session transcript must not be empty"
}

$scoreTotal = 0
foreach ($competency in $competencyNames) {
    $scoreEntry = $session.evaluation.scores.PSObject.Properties[$competency]
    if (-not $scoreEntry) {
        throw "Evaluation is missing competency: $competency"
    }
    $score = $scoreEntry.Value.score
    if ($score -isnot [long] -and $score -isnot [int]) {
        throw "Score must be an integer for ${competency}: $score"
    }
    if ($score -lt 0 -or $score -gt 5) {
        throw "Score must be between 0 and 5 for ${competency}: $score"
    }
    $scoreTotal += $score
}

$calculatedOverall = [Math]::Round($scoreTotal / $competencyNames.Count, 2)
if ([Math]::Abs([double]$session.evaluation.overall - $calculatedOverall) -gt 0.01) {
    throw "Overall score $($session.evaluation.overall) does not match calculated score $calculatedOverall"
}

if (-not $session.reflection.bottleneckCompetency -or -not $session.reflection.nextBehavior) {
    throw "Reflection must define bottleneckCompetency and nextBehavior"
}
if ($session.reflection.bottleneckCompetency -notin $competencyNames) {
    throw "Unknown bottleneck competency: $($session.reflection.bottleneckCompetency)"
}

New-Item -ItemType Directory -Force -Path $sessionsDirectory, $exportsDirectory | Out-Null
$destinationPath = Join-Path $sessionsDirectory "$($session.sessionId).json"
if (Test-Path $destinationPath) {
    throw "Session has already been completed: $($session.sessionId)"
}
$transactionId = [guid]::NewGuid().ToString("N")
$temporaryProfilePath = "$profilePath.$transactionId.tmp"
$temporarySessionPath = "$destinationPath.$transactionId.tmp"
$temporaryProgressPath = "$progressPath.$transactionId.tmp"

if (-not $profile.learner.startedAt) {
    $profile.learner.startedAt = $session.startedAt
}
$profile.sessionCount = [int]$profile.sessionCount + 1

foreach ($competency in $competencyNames) {
    $score = [int]$session.evaluation.scores.$competency.score
    $current = $profile.competencies.$competency
    $attempts = [int]$current.attempts
    $previousTotal = if ($attempts -eq 0 -or $null -eq $current.average) { 0 } else { [double]$current.average * $attempts }
    $current.attempts = $attempts + 1
    $current.average = [Math]::Round(($previousTotal + $score) / $current.attempts, 2)
}

function Add-CoverageCount {
    param([object]$Bucket, [string]$Name)
    if (-not $Name) { return }
    $existing = $Bucket.PSObject.Properties[$Name]
    if ($existing) {
        $existing.Value = [int]$existing.Value + 1
    } else {
        $Bucket | Add-Member -NotePropertyName $Name -NotePropertyValue 1
    }
}

Add-CoverageCount $profile.coverage.industries $session.scenario.industry
Add-CoverageCount $profile.coverage.businessFunctions $session.scenario.businessFunction
Add-CoverageCount $profile.coverage.personas $session.scenario.persona
foreach ($technologyArea in $session.scenario.technologyAreas) {
    Add-CoverageCount $profile.coverage.technologyAreas $technologyArea
}
foreach ($lane in $session.scenario.capabilityLanes) {
    Add-CoverageCount $profile.coverage.capabilityLanes $lane
}

$profile.recurringWeaknesses = @($session.reflection.recurringWeaknesses | Where-Object { $_ } | Select-Object -Unique)
$profile.masteredBehaviors = @(
    @($profile.masteredBehaviors) + @($session.reflection.masteredBehaviors) |
        Where-Object { $_ } |
        Select-Object -Unique
)
$profile.nextFocus.competency = $session.reflection.bottleneckCompetency
$profile.nextFocus.behavior = $session.reflection.nextBehavior

if ($session.mode -eq "benchmark") {
    $profile.benchmarkHistory = @($profile.benchmarkHistory) + @([pscustomobject]@{
        sessionId = $session.sessionId
        scenarioId = $session.scenario.scenarioId
        completedAt = $session.completedAt
        overall = $calculatedOverall
    })
}
$profile.updatedAt = $session.completedAt

$progressRow = [pscustomobject]@{
    sessionId = $session.sessionId
    completedAt = $session.completedAt
    mode = $session.mode
    scenarioId = $session.scenario.scenarioId
    industry = $session.scenario.industry
    persona = $session.scenario.persona
    overall = $calculatedOverall
    businessOutcome = $session.evaluation.scores.businessOutcome.score
    roiAndTco = $session.evaluation.scores.roiAndTco.score
    assumptionsAndMeasurement = $session.evaluation.scores.assumptionsAndMeasurement.score
    riskAndGovernance = $session.evaluation.scores.riskAndGovernance.score
    industryTransformation = $session.evaluation.scores.industryTransformation.score
    executiveRecommendation = $session.evaluation.scores.executiveRecommendation.score
    nextFocus = $session.reflection.bottleneckCompetency
}

try {
    $profile | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 $temporaryProfilePath
    $session | ConvertTo-Json -Depth 30 | Set-Content -Encoding UTF8 $temporarySessionPath

    if (Test-Path $progressPath) {
        Copy-Item $progressPath $temporaryProgressPath
        $progressRow | Export-Csv -NoTypeInformation -Encoding UTF8 -Append $temporaryProgressPath
    } else {
        $progressRow | Export-Csv -NoTypeInformation -Encoding UTF8 $temporaryProgressPath
    }

    Get-Content -Raw -Encoding UTF8 $temporaryProfilePath | ConvertFrom-Json | Out-Null
    Get-Content -Raw -Encoding UTF8 $temporarySessionPath | ConvertFrom-Json | Out-Null
    Import-Csv $temporaryProgressPath | Out-Null

    Move-Item -Force $temporaryProfilePath $profilePath
    Move-Item -Force $temporarySessionPath $destinationPath
    Move-Item -Force $temporaryProgressPath $progressPath
    Remove-Item $ActiveSessionPath
} finally {
    Remove-Item -Force -ErrorAction SilentlyContinue $temporaryProfilePath, $temporarySessionPath, $temporaryProgressPath
}

Write-Output "Completed session $($session.sessionId). Overall: $calculatedOverall; Next focus: $($profile.nextFocus.competency)"