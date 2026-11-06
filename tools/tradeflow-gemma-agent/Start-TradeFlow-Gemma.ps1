param(
    [string]$TaskFile = "tasks/example.json",
    [switch]$Enqueue
)

$ErrorActionPreference = "Stop"
$AgentRoot = $PSScriptRoot
# TradeFlow has its own local configuration. Never read or modify the retired GearCashOut .env.
$EnvFile = Join-Path $AgentRoot ".env"
$TaskPath = if ([System.IO.Path]::IsPathRooted($TaskFile)) { $TaskFile } else { Join-Path $AgentRoot $TaskFile }

if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) {
    throw "TradeFlow .env is missing from the agent folder. Create it from .env.example and keep GearCashOut configuration separate."
}
if (-not (Test-Path -LiteralPath $TaskPath -PathType Leaf)) {
    throw "Task file not found: $TaskPath"
}

$null = Get-Command node -ErrorAction Stop
$null = Get-Command npm -ErrorAction Stop
$null = Get-Command ollama -ErrorAction Stop

$EnvText = Get-Content -LiteralPath $EnvFile -Raw
$RequiredKeys = @(
    "TRADEFLOW_TEST_URL",
    "TRADEFLOW_TEST_SERVICE_ROLE_KEY",
    "TRADEFLOW_LIVE_URL",
    "TRADEFLOW_LIVE_SERVICE_ROLE_KEY"
)
foreach ($Key in $RequiredKeys) {
    if ($EnvText -notmatch "(?m)^\s*$Key\s*=\s*\S+") {
        throw "Required local setting is missing: $Key. The value will not be displayed."
    }
}

foreach ($Target in @(
    @{ Name = "TEST"; Host = "nnsshnfkjcflucjrftzi.supabase.co" },
    @{ Name = "LIVE"; Host = "gxsrajtqzdjvmceqcpgv.supabase.co" }
)) {
    $Match = [regex]::Match($EnvText, "(?m)^\s*TRADEFLOW_$($Target.Name)_URL\s*=\s*(\S+)")
    if (-not $Match.Success) { throw "Missing TradeFlow $($Target.Name) URL." }
    try { $ParsedUrl = [uri]$Match.Groups[1].Value.Trim('"').Trim("'") }
    catch { throw "TradeFlow $($Target.Name) URL is invalid." }
    if ($ParsedUrl.Host -ne $Target.Host -or $ParsedUrl.Scheme -ne "https") {
        throw "TradeFlow $($Target.Name) URL does not match the expected project. No connection was made."
    }
}

$Models = & ollama list 2>$null
if ($LASTEXITCODE -ne 0) { throw "Ollama is not responding. Start Ollama and retry." }
$ModelMatch = [regex]::Match($EnvText, "(?m)^\s*OLLAMA_MODEL\s*=\s*(\S+)")
$ModelTag = if ($ModelMatch.Success) { $ModelMatch.Groups[1].Value.Trim('"').Trim("'") } else { "gemma3:4b" }
$ModelPattern = "(?m)^" + [regex]::Escape($ModelTag) + "\s"
if (($Models -join [Environment]::NewLine) -notmatch $ModelPattern) {
    throw "Ollama model $ModelTag is not installed. Set OLLAMA_MODEL in TradeFlow .env to an installed Gemma model."
}

Push-Location $AgentRoot
try {
    Write-Host "Checking local SearXNG search service..."
    $SearchMatch = [regex]::Match($EnvText, "(?m)^\s*SEARXNG_BASE_URL\s*=\s*(\S+)")
    $ConfiguredSearchUrl = if ($SearchMatch.Success) { $SearchMatch.Groups[1].Value.Trim('"').Trim("'") } else { "http://127.0.0.1:8080" }

    # Prefer the configured endpoint, but fall back to the known local Compose binding.
    # This avoids a stale/incorrect .env URL blocking a healthy local SearXNG instance.
    $SearchCandidates = @($ConfiguredSearchUrl, "http://127.0.0.1:8080") | Select-Object -Unique
    $SearchCheck = $null
    $SearchErrors = @()
    foreach ($Candidate in $SearchCandidates) {
        try {
            $SearchUri = [uri]$Candidate
            if ($SearchUri.Scheme -notin @("http", "https")) { throw "Search URL must use HTTP or HTTPS." }
            $SearchEndpoint = $SearchUri.GetLeftPart([System.UriPartial]::Authority) + "/search?q=tradeflow&format=json"
            $CandidateCheck = Invoke-RestMethod -Uri $SearchEndpoint -TimeoutSec 8
            if ($null -eq $CandidateCheck.results) { throw "Endpoint did not return SearXNG JSON results." }
            $SearchCheck = $CandidateCheck
            Write-Host "SearXNG responding at $($SearchUri.GetLeftPart([System.UriPartial]::Authority))"
            break
        }
        catch {
            $SearchErrors += ($Candidate + ": " + $_.Exception.Message)
        }
    }
    if ($null -eq $SearchCheck) {
        throw ("SearXNG did not respond at the configured address or the local fallback. " + ($SearchErrors -join " | "))
    }

    Write-Host "Running Gemma validation tests..."
    & npm test
    if ($LASTEXITCODE -ne 0) { throw "Gemma tests failed; research run stopped." }

    $NpmArgs = @("start", "--", $TaskPath)
    if ($Enqueue) {
        Write-Host "ENQUEUE mode: candidates may be staged in the TEST review queue. No master catalogue or evidence rows are imported."
        $NpmArgs += "--enqueue"
    }
    else {
        Write-Host "DRY-RUN mode: source research and read-only TEST/LIVE product checks. Agent telemetry is recorded; no queue or catalogue rows are written."
    }

    # Pass the exact TradeFlow .env path to Node; no other .env file is consulted.
    $env:TRADEFLOW_GEMMA_ENV_FILE = $EnvFile
    & npm @NpmArgs
    if ($LASTEXITCODE -ne 0) { throw "Gemma task failed. Review the failed-closed output before retrying." }
}
finally {
    Pop-Location
}
