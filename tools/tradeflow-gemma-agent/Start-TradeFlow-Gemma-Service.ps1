$ErrorActionPreference = "Stop"
$AgentRoot = $PSScriptRoot
$EnvFile = Join-Path $AgentRoot ".env"
$LogRoot = Join-Path $AgentRoot "logs"
$LogFile = Join-Path $LogRoot "gemma-supervisor.log"
New-Item -ItemType Directory -Force -Path $LogRoot | Out-Null
if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) { throw "TradeFlow .env not found in the agent folder. The old GearCashOut config is not used or modified." }
$null = Get-Command node -ErrorAction Stop
$env:TRADEFLOW_GEMMA_ENV_FILE = $EnvFile
Set-Location $AgentRoot
"[$(Get-Date -Format o)] TradeFlow Gemma supervisor started." | Add-Content -LiteralPath $LogFile
while ($true) {
    "[$(Get-Date -Format o)] Starting background task worker." | Add-Content -LiteralPath $LogFile
    try {
        & node (Join-Path $AgentRoot "src\task-worker.mjs") *>> $LogFile
        $ExitCode = $LASTEXITCODE
        "[$(Get-Date -Format o)] Worker exited with code $ExitCode." | Add-Content -LiteralPath $LogFile
    }
    catch {
        "[$(Get-Date -Format o)] Worker launch error: $($_.Exception.Message)" | Add-Content -LiteralPath $LogFile
    }
    Start-Sleep -Seconds 10
}
