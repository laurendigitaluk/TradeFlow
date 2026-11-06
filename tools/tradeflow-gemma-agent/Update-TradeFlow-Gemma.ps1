param([string]$AgentRoot = $PSScriptRoot)
$ErrorActionPreference = "Stop"
$Branch = "feature/tradeflow-gemma-agent-foundation-20261105"
$RepoArchive = "https://codeload.github.com/laurendigitaluk/TradeFlow/zip/refs/heads/$Branch"
$TempRoot = Join-Path ([IO.Path]::GetTempPath()) ("TradeFlow-Gemma-Update-" + [guid]::NewGuid().ToString("N"))
$StageRoot = Join-Path $TempRoot "stage"
$BackupRoot = Join-Path $TempRoot "backup"
$ZipPath = Join-Path $TempRoot "tradeflow.zip"
function Copy-AgentCode([string]$Source, [string]$Destination) {
    Get-ChildItem -LiteralPath $Source -Force | Where-Object { $_.Name -notin @(".env", "tasks", "logs", "node_modules", "Update-TradeFlow-Gemma.ps1") } | ForEach-Object {
        $target = Join-Path $Destination $_.Name
        if ($_.PSIsContainer) { if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }; Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force }
        else { Copy-Item -LiteralPath $_.FullName -Destination $target -Force }
    }
}
function Restore-AgentCode([string]$Backup, [string]$Destination) {
    $keep = @(".env", "tasks", "logs", "node_modules", "Update-TradeFlow-Gemma.ps1")
    Get-ChildItem -LiteralPath $Destination -Force | Where-Object { $_.Name -notin $keep } | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }
    Copy-AgentCode -Source $Backup -Destination $Destination
}
try {
    if (-not (Test-Path -LiteralPath $AgentRoot -PathType Container)) { throw "TradeFlow Gemma folder not found: $AgentRoot" }
    $AgentRoot = (Resolve-Path -LiteralPath $AgentRoot).Path
    if (-not (Test-Path -LiteralPath (Join-Path $AgentRoot ".env") -PathType Leaf)) { throw "TradeFlow .env is missing. Update stopped without changing files." }
    if (-not (Test-Path -LiteralPath (Join-Path $AgentRoot "Start-TradeFlow-Gemma.ps1"))) { throw "This does not look like the TradeFlow Gemma agent folder. Update stopped." }
    $null = Get-Command node -ErrorAction Stop
    $NodeVersion = (& node --version).Trim()
    if ([int]($NodeVersion.TrimStart("v").Split(".")[0]) -lt 22) { throw "Node.js 22 or newer is required; found $NodeVersion." }
    New-Item -ItemType Directory -Path $TempRoot, $StageRoot, $BackupRoot -Force | Out-Null
    Write-Host "Downloading the approved TradeFlow feature branch..."
    Invoke-WebRequest -Uri $RepoArchive -OutFile $ZipPath
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $StageRoot -Force
    $Extracted = Get-ChildItem -LiteralPath $StageRoot -Directory | Select-Object -First 1
    if (-not $Extracted) { throw "GitHub archive did not contain an extracted repository folder." }
    $SourceAgent = Join-Path $Extracted.FullName "tools/tradeflow-gemma-agent"
    if (-not (Test-Path -LiteralPath (Join-Path $SourceAgent "src/agent.mjs")) -or -not (Test-Path -LiteralPath (Join-Path $SourceAgent "Start-TradeFlow-Gemma.ps1"))) { throw "Downloaded archive is missing expected TradeFlow Gemma files." }
    Copy-AgentCode -Source $AgentRoot -Destination $BackupRoot
    Write-Host "Updating code. Existing .env, tasks, logs and node_modules are preserved..."
    Copy-AgentCode -Source $SourceAgent -Destination $AgentRoot
    Push-Location $AgentRoot
    try {
        Write-Host "Running the updated Gemma test suite..."
        & npm test
        if ($LASTEXITCODE -ne 0) { throw "Updated test suite failed. Restoring previous code." }
    } finally { Pop-Location }
    Write-Host "TradeFlow Gemma update and tests completed successfully."
    Write-Host "Existing TradeFlow .env, tasks and logs were preserved."
} catch {
    if ((Test-Path -LiteralPath $BackupRoot) -and (Test-Path -LiteralPath $AgentRoot)) {
        Write-Warning "Update failed. Restoring the previous agent code..."
        Restore-AgentCode -Backup $BackupRoot -Destination $AgentRoot
        Write-Warning "Previous code restored. Existing .env, tasks and logs were not changed."
    }
    throw
} finally {
    if (Test-Path -LiteralPath $TempRoot) { Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue }
}
