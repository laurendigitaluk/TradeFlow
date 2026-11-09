param(
    [string]$AgentKey,
    [switch]$EnableAgent
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $AppRoot 'config.json'
$StatusPath = Join-Path $AppRoot 'status.json'
$LogPath = Join-Path $AppRoot 'logs'
$TaskName = 'TradeFlow Gemma Research Supervisor'
$AgentsPath = Join-Path $AppRoot 'agents.json'
$Agents = (Get-Content -LiteralPath $AgentsPath -Raw | ConvertFrom-Json).agents
$UiState = [pscustomobject]@{ Updating = $false }

function Read-Config {
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        return [pscustomobject]@{ schemaVersion=1; serviceEnabled=$false; autoStart=$true; enabledAgentKeys=@($Agents | ForEach-Object { $_.agentKey }) }
    }
    $value = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    if ([int]$value.schemaVersion -ne 1) { throw 'Unsupported desktop configuration version. Re-run the installer.' }
    return $value
}
function Save-Config($Value) {
    $Value | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $ConfigPath -Encoding UTF8
}
function Ensure-AgentEnabled([string]$Key) {
    $agent = $Agents | Where-Object { $_.agentKey -eq $Key } | Select-Object -First 1
    if (-not $agent) { throw "Unknown research agent: $Key" }
    $config = Read-Config
    $keys = @($config.enabledAgentKeys)
    if ($keys -notcontains $Key) { $keys += $Key }
    $config.enabledAgentKeys = @($keys | Select-Object -Unique)
    $config.serviceEnabled = $true
    Save-Config $config
}
function Start-BackgroundService {
    $config = Read-Config
    $config.serviceEnabled = $true
    Save-Config $config
    try { Start-ScheduledTask -TaskName $TaskName -ErrorAction Stop } catch {
        if ($_.Exception.Message -notmatch 'already running|running') { throw }
    }
}
function Stop-BackgroundService {
    $config = Read-Config
    $config.serviceEnabled = $false
    Save-Config $config
    # The worker reads this setting between tasks. Do not terminate a running task.
}
function Set-AgentEnabled([string]$Key,[bool]$Enabled) {
    $config = Read-Config
    $keys = @($config.enabledAgentKeys)
    if ($Enabled) {
        if ($keys -notcontains $Key) { $keys += $Key }
        $config.serviceEnabled = $true
    } else {
        $keys = @($keys | Where-Object { $_ -ne $Key })
    }
    $config.enabledAgentKeys = @($keys | Select-Object -Unique)
    Save-Config $config
    if ($Enabled) { Start-BackgroundService }
}
function Read-Status {
    if (-not (Test-Path -LiteralPath $StatusPath -PathType Leaf)) { return $null }
    try { return (Get-Content -LiteralPath $StatusPath -Raw | ConvertFrom-Json) } catch { return $null }
}
function Get-AgentState([string]$Key,$Config,$Status) {
    if (-not $Config.serviceEnabled) { return 'SERVICE STOPPED' }
    if (@($Config.enabledAgentKeys) -notcontains $Key) { return 'DISABLED' }
    if ($Status -and $Status.state -eq 'requires_migration') { return 'BACKEND UPDATE REQUIRED' }
    if ($Status -and @($Status.activeAgentKeys) -contains $Key) { return 'RUNNING — processing a research task' }
    if ($Status -and $Status.state -eq 'error') { return 'ERROR — see logs' }
    return 'WAITING — enabled; no matching task is currently assigned'
}
function Update-Display {
    $UiState.Updating = $true
    $config = Read-Config
    $status = Read-Status
    if (-not $config.serviceEnabled) {
        $ServiceLabel.Text = 'Background service: stopped'
    } elseif ($status -and $status.state -eq 'requires_migration') {
        $ServiceLabel.Text = 'Background service: backend update required — apply the agent-scoped queue migration'
    } elseif ($status -and $status.state -eq 'processing') {
        $ServiceLabel.Text = 'Background service: processing ' + [string]$status.activeTaskKey
    } elseif ($status -and $status.state -eq 'error') {
        $ServiceLabel.Text = 'Background service: error — open logs'
    } else {
        $ServiceLabel.Text = 'Background service: connected / waiting for website tasks'
    }
    $enabledCount = @($config.enabledAgentKeys).Count
    $activeCount = if ($status -and $status.activeAgentKeys) { @($status.activeAgentKeys).Count } else { 0 }
    $AgentSummary.Text = "Specialists enabled: $enabledCount / $($Agents.Count)    |    Active research tasks: $activeCount"
    foreach ($agent in $Agents) {
        $ui = $AgentControls[$agent.agentKey]
        $enabled = @($config.enabledAgentKeys) -contains $agent.agentKey
        $ui.Check.Checked = $enabled
        $ui.State.Text = Get-AgentState $agent.agentKey $config $status
        $ui.State.ForeColor = if (-not $config.serviceEnabled -or -not $enabled) { [System.Drawing.Color]::DimGray } elseif ($status -and $status.activeAgentKeys -contains $agent.agentKey) { [System.Drawing.Color]::ForestGreen } else { [System.Drawing.Color]::DarkSlateBlue }
    }
    $UiState.Updating = $false
}

if ($AgentKey -and $EnableAgent) {
    Ensure-AgentEnabled $AgentKey
    Start-BackgroundService
}

# Keep one visible Control Centre. Specialist shortcuts update shared config above,
# then exit if the existing dashboard already owns this per-user mutex.
$script:UiMutex = New-Object System.Threading.Mutex($false, 'Local\TradeFlowResearchControlCentre')
if (-not $script:UiMutex.WaitOne(0, $false)) {
    $script:UiMutex.Dispose()
    exit 0
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'TradeFlow Research Control Centre'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(1040,780)
$form.MinimumSize = New-Object System.Drawing.Size(860,560)
$form.BackColor = [System.Drawing.Color]::FromArgb(246,248,250)
$form.Font = New-Object System.Drawing.Font('Segoe UI',9)
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi

$header = New-Object System.Windows.Forms.Panel
$header.Dock = 'Top'
$header.Height = 86
$header.BackColor = [System.Drawing.Color]::FromArgb(28,42,58)
$form.Controls.Add($header)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'TRADEFLOW  |  RESEARCH CONTROL CENTRE'
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold',15,[System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(22,12)
$title.AutoSize = $true
$header.Controls.Add($title)

$ServiceLabel = New-Object System.Windows.Forms.Label
$ServiceLabel.Text = 'Background service: checking…'
$ServiceLabel.ForeColor = [System.Drawing.Color]::FromArgb(225,232,239)
$ServiceLabel.Location = New-Object System.Drawing.Point(24,52)
$ServiceLabel.AutoSize = $true
$header.Controls.Add($ServiceLabel)

$buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonPanel.Dock = 'Top'
$buttonPanel.Height = 48
$buttonPanel.Padding = New-Object System.Windows.Forms.Padding(14,7,8,5)
$buttonPanel.BackColor = [System.Drawing.Color]::White
$buttonPanel.WrapContents = $false
$form.Controls.Add($buttonPanel)

$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = 'Start background service'
$startButton.Width = 180
$startButton.Height = 30
$startButton.FlatStyle = 'Flat'
$startButton.BackColor = [System.Drawing.Color]::FromArgb(33,112,82)
$startButton.ForeColor = [System.Drawing.Color]::White
$startButton.Add_Click({ try { Start-BackgroundService; Update-Display } catch { [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'TradeFlow') } }.GetNewClosure())
$buttonPanel.Controls.Add($startButton)

$stopButton = New-Object System.Windows.Forms.Button
$stopButton.Text = 'Stop after current task'
$stopButton.Width = 165
$stopButton.Height = 30
$stopButton.FlatStyle = 'Flat'
$stopButton.Add_Click({ Stop-BackgroundService; Update-Display }.GetNewClosure())
$buttonPanel.Controls.Add($stopButton)

$logsButton = New-Object System.Windows.Forms.Button
$logsButton.Text = 'Open logs'
$logsButton.Width = 90
$logsButton.Height = 30
$logsButton.Add_Click({ New-Item -ItemType Directory -Path $LogPath -Force | Out-Null; Invoke-Item $LogPath }.GetNewClosure())
$buttonPanel.Controls.Add($logsButton)

$AgentSummary = New-Object System.Windows.Forms.Label
$AgentSummary.Text = 'Specialists enabled: checking…'
$AgentSummary.AutoSize = $true
$AgentSummary.Margin = New-Object System.Windows.Forms.Padding(12,8,4,4)
$AgentSummary.ForeColor = [System.Drawing.Color]::FromArgb(45,58,72)
$buttonPanel.Controls.Add($AgentSummary)

$note = New-Object System.Windows.Forms.Label
$note.Text = 'Each specialist has an independent switch. Enabled specialists wait for matching TradeFlow LIVE work; only an active task shows RUNNING.'
$note.Dock = 'Top'
$note.Height = 38
$note.Padding = New-Object System.Windows.Forms.Padding(18,9,12,5)
$note.BackColor = [System.Drawing.Color]::FromArgb(246,248,250)
$note.ForeColor = [System.Drawing.Color]::FromArgb(70,82,94)
$form.Controls.Add($note)

# A fixed two-column grid deliberately replaces scrolling. Four compact rows fit
# the seven named specialists in the owner's side-by-side desktop window.
$listHost = New-Object System.Windows.Forms.Panel
$listHost.Dock = 'Fill'
$listHost.BackColor = [System.Drawing.Color]::FromArgb(246,248,250)
$listHost.Padding = New-Object System.Windows.Forms.Padding(8,6,8,6)
$form.Controls.Add($listHost)

$AgentControls = @{}
$agentIndex = 0
foreach ($agent in $Agents) {
    $card = New-Object System.Windows.Forms.Panel
    $card.Height = 78
    $card.Margin = New-Object System.Windows.Forms.Padding(4)
    $card.Padding = New-Object System.Windows.Forms.Padding(8)
    $card.BackColor = [System.Drawing.Color]::White
    $card.BorderStyle = 'FixedSingle'

    $name = New-Object System.Windows.Forms.Label
    $name.Text = [string]$agent.label
    $name.Font = New-Object System.Drawing.Font('Segoe UI Semibold',10,[System.Drawing.FontStyle]::Bold)
    $name.Location = New-Object System.Drawing.Point(10,7)
    $name.AutoSize = $true
    $card.Controls.Add($name)

    $state = New-Object System.Windows.Forms.Label
    $state.Text = 'Checking…'
    $state.Location = New-Object System.Drawing.Point(10,31)
    $state.Width = 420
    $state.Height = 20
    $state.ForeColor = [System.Drawing.Color]::DarkSlateBlue
    $card.Controls.Add($state)

    $check = New-Object System.Windows.Forms.CheckBox
    $check.Text = 'Enabled'
    $check.Tag = [string]$agent.agentKey
    $check.Location = New-Object System.Drawing.Point(10,52)
    $check.AutoSize = $true
    $check.Add_CheckedChanged({
        param($sender,$eventArgs)
        if (-not $UiState.Updating -and $sender.Tag) {
            try { Set-AgentEnabled ([string]$sender.Tag) ([bool]$sender.Checked); Update-Display }
            catch { [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'TradeFlow') }
        }
    }.GetNewClosure())
    $card.Controls.Add($check)

    $listHost.Controls.Add($card)
    $AgentControls[[string]$agent.agentKey] = @{ Check=$check; State=$state; Card=$card; Index=$agentIndex }
    $agentIndex++
}

$script:UpdatingAgentGrid = $false
$script:UpdateAgentGrid = {
    if ($script:UpdatingAgentGrid) { return }
    $script:UpdatingAgentGrid = $true
    try {
        $hostWidth = [Math]::Max(1, $listHost.ClientSize.Width)
        $hostHeight = [Math]::Max(1, $listHost.ClientSize.Height)
        $columns = 2
        $gap = 8
        $outer = 8
        $cardWidth = [Math]::Max(280, [int](($hostWidth - (2 * $outer) - $gap) / 2))
        $cardHeight = [Math]::Max(66, [Math]::Min(78, [int](($hostHeight - (4 * $outer)) / 4) - 6))
        foreach ($item in $AgentControls.Values) {
            $column = $item.Index % $columns
            $row = [Math]::Floor($item.Index / $columns)
            $x = $outer + ($column * ($cardWidth + $gap))
            $y = $outer + ($row * ($cardHeight + $gap))
            $item.Card.SetBounds($x, $y, $cardWidth, $cardHeight)
            $item.State.Width = [Math]::Max(180, $cardWidth - 24)
        }
    } finally {
        $script:UpdatingAgentGrid = $false
    }
}.GetNewClosure()

$listHost.Add_Resize({ & $script:UpdateAgentGrid }.GetNewClosure())
$form.Add_Shown({
    $form.BeginInvoke([Action]{ & $script:UpdateAgentGrid }) | Out-Null
    Update-Display
    $timer.Start()
}.GetNewClosure())

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 3000
$timer.Add_Tick({ Update-Display }.GetNewClosure())
$form.Add_FormClosed({ $timer.Stop(); try { $script:UiMutex.ReleaseMutex() } catch {}; $script:UiMutex.Dispose() }.GetNewClosure())
[void]$form.ShowDialog()
