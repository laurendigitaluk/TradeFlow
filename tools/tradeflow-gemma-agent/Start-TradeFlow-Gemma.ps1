param(
    [string]$TaskFile = "tasks/example.json",
    [switch]$Apply
)

$ErrorActionPreference = "Stop"
$AgentRoot = $PSScriptRoot
$EnvFile = Join-Path $AgentRoot ".env"
$TaskPath = if ([System.IO.Path]::IsPathRooted($TaskFile)) { $TaskFile } else { Join-Path $AgentRoot $TaskFile }

if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) {
    throw "Missing local .env. Copy .env.example to .env and configure Ollama, Brave Search and both TradeFlow environments."
}
if (-not (Test-Path -LiteralPath $TaskPath -PathType Leaf)) {
    throw "Task file not found: $TaskPath"
}

$null = Get-Command node -ErrorAction Stop
$null = Get-Command npm -ErrorAction Stop
$null = Get-Command ollama -ErrorAction Stop

$EnvText = Get-Content -LiteralPath $EnvFile -Raw
$RequiredKeys = @(
    "BRAVE_SEARCH_API_KEY",
    "TRADEFLOW_TEST_SERVICE_ROLE_KEY",
    "TRADEFLOW_LIVE_SERVICE_ROLE_KEY"
)
foreach ($Key in $RequiredKeys) {
    if ($EnvText -notmatch "(?m)^\s*$Key\s*=\s*\S+") {
        throw "Required local setting is missing: $Key. The value will not be displayed."
    }
}

$Models = & ollama list 2>$null
if ($LASTEXITCODE -ne 0) { throw "Ollama is not responding. Start Ollama and retry." }
$ModelMatch = [regex]::Match($EnvText, "(?m)^\s*OLLAMA_MODEL\s*=\s*(\S+)")
$ModelTag = if ($ModelMatch.Success) { $ModelMatch.Groups[1].Value.Trim('"').Trim("'") } else { "gemma3:4b" }
$ModelPattern = "(?m)^" + [regex]::Escape($ModelTag) + "\s"
if (($Models -join "`n") -notmatch $ModelPattern) {
    throw "Ollama model $ModelTag is not installed. Set OLLAMA_MODEL in .env to an installed Gemma model."
}

Push-Location $AgentRoot
try {
    Write-Host "Running Gemma validation tests..."
    & npm test
    if ($LASTEXITCODE -ne 0) { throw "Gemma tests failed; research run stopped." }

    $NpmArgs = @("start", "--", $TaskPath)
    if ($Apply) {
        Write-Host "APPLY mode selected: verified candidates may be written separately to TEST and LIVE."
        $NpmArgs += "--apply"
    }
    else {
        Write-Host "DRY-RUN mode selected: no catalogue evidence will be written."
    }

    & npm @NpmArgs
    if ($LASTEXITCODE -ne 0) { throw "Gemma task failed. Review the failed-closed output before retrying." }
}
finally {
    Pop-Location
}
