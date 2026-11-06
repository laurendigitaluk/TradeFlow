param([string]$AgentRoot = $PSScriptRoot)
$ErrorActionPreference = "Stop"
$Branch = "feature/tradeflow-gemma-agent-foundation-20261105"
$RepoArchive = "https://codeload.github.com/laurendigitaluk/TradeFlow/zip/refs/heads/$Branch"
# Keep every temporary path short; Windows PowerShell Expand-Archive can fail on
# unrelated long paths elsewhere in the full repository archive.
$TempRoot = Join-Path $env:SystemDrive ("TFG-" + [guid]::NewGuid().ToString("N").Substring(0,8))
$StageRoot = Join-Path $TempRoot "stage"
$BackupRoot = Join-Path $TempRoot "backup"
$ZipPath = Join-Path $TempRoot "repo.zip"
$BackupComplete = $false

function Copy-AgentCode([string]$Source, [string]$Destination) {
    Get-ChildItem -LiteralPath $Source -Force | Where-Object {
        $_.Name -notin @(".env", "tasks", "logs", "node_modules", "Update-TradeFlow-Gemma.ps1")
    } | ForEach-Object {
        $target = Join-Path $Destination $_.Name
        if ($_.PSIsContainer) {
            if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
            Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
        } else {
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        }
    }
}
function Restore-AgentCode([string]$Backup, [string]$Destination) {
    $keep = @(".env", "tasks", "logs", "node_modules", "Update-TradeFlow-Gemma.ps1")
    Get-ChildItem -LiteralPath $Destination -Force | Where-Object {
        $_.Name -notin $keep
    } | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }
    Copy-AgentCode -Source $Backup -Destination $Destination
}
try {
    if (-not (Test-Path -LiteralPath $AgentRoot -PathType Container)) { throw "TradeFlow Gemma folder not found: $AgentRoot" }
    $AgentRoot = (Resolve-Path -LiteralPath $AgentRoot).Path
    if (-not (Test-Path -LiteralPath (Join-Path $AgentRoot ".env") -PathType Leaf)) { throw "TradeFlow .env is missing. Update stopped without changing files." }
    $null = Get-Command node -ErrorAction Stop
    $NodeVersion = (& node --version).Trim()
    if ([int]($NodeVersion.TrimStart("v").Split(".")[0]) -lt 22) { throw "Node.js 22 or newer is required; found $NodeVersion." }

    New-Item -ItemType Directory -Path $TempRoot, $StageRoot, $BackupRoot -Force | Out-Null
    # Take and verify a complete code backup BEFORE any archive extraction or replacement.
    Copy-AgentCode -Source $AgentRoot -Destination $BackupRoot
    $BackupComplete = (Test-Path -LiteralPath (Join-Path $BackupRoot "Start-TradeFlow-Gemma.ps1") -PathType Leaf) -and
        (Test-Path -LiteralPath (Join-Path $BackupRoot "src/agent.mjs") -PathType Leaf)
    if (-not $BackupComplete) {
        Write-Warning "The previous code is incomplete; proceeding with a clean repair from GitHub. A rollback will not be attempted unless a complete backup exists."
    }

    Write-Host "Downloading the approved TradeFlow feature branch..."
    Invoke-WebRequest -Uri $RepoArchive -OutFile $ZipPath
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
        $prefix = ($archive.Entries | Where-Object { $_.FullName -match '^[^/]+/tools/tradeflow-gemma-agent/' } | Select-Object -First 1).FullName
        if (-not $prefix) { throw "GitHub archive does not contain the TradeFlow Gemma agent folder." }
        $prefix = $prefix.Substring(0, $prefix.IndexOf("tools/tradeflow-gemma-agent/")) + "tools/tradeflow-gemma-agent/"
        foreach ($entry in $archive.Entries) {
            if (-not $entry.FullName.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { continue }
            $relative = $entry.FullName.Substring($prefix.Length).Replace("/", "\")
            if (-not $relative -or $relative -match '(^|\\)(\.env|tasks|logs|node_modules)(\\|$)') { continue }
            if ($relative -eq "Update-TradeFlow-Gemma.ps1") { continue }
            $destination = Join-Path $StageRoot $relative
            if ($entry.FullName.EndsWith("/")) {
                New-Item -ItemType Directory -Path $destination -Force | Out-Null
                continue
            }
            $parent = Split-Path -Parent $destination
            if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destination, $true)
        }
    } finally {
        $archive.Dispose()
    }
    if (-not (Test-Path -LiteralPath (Join-Path $StageRoot "src/agent.mjs") -PathType Leaf) -or
        -not (Test-Path -LiteralPath (Join-Path $StageRoot "Start-TradeFlow-Gemma.ps1") -PathType Leaf)) {
        throw "The staged TradeFlow agent files are incomplete. Local code has not been changed."
    }

    Write-Host "Updating code. Existing .env, tasks, logs and node_modules are preserved..."
    Copy-AgentCode -Source $StageRoot -Destination $AgentRoot
    Push-Location $AgentRoot
    try {
        Write-Host "Running the updated Gemma test suite..."
        & npm test
        if ($LASTEXITCODE -ne 0) { throw "Updated test suite failed." }
    } finally { Pop-Location }
    Write-Host "TradeFlow Gemma update and tests completed successfully."
    Write-Host "Existing TradeFlow .env, tasks and logs were preserved."
} catch {
    if ($BackupComplete -and (Test-Path -LiteralPath $BackupRoot) -and (Test-Path -LiteralPath $AgentRoot)) {
        Write-Warning "Update failed after backup. Restoring the previous agent code..."
        Restore-AgentCode -Backup $BackupRoot -Destination $AgentRoot
        Write-Warning "Previous agent code restored. Existing .env, tasks and logs were not changed."
    } else {
        Write-Warning "No verified backup was created, so no rollback or destructive cleanup was attempted."
    }
    throw
} finally {
    if (Test-Path -LiteralPath $TempRoot) { Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue }
}
