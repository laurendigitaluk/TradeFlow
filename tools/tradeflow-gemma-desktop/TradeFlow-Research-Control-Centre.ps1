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
$script:UpdatingUI = $false

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
    if (-not $Config.serviceEnabled) { return 'Service stopped' }
    if (@($Config.enabledAgentKeys) -notcontains $Key) { return 'Disabled' }
    if ($Status -and $Status.state -eq 'requires_migration') { return 'Backend update required' }
    if ($Status -and @($Status.activeAgentKeys) -contains $Key) { return 'Running a research task' }
    if ($Status -and $Status.state -eq 'error') { return 'Worker error — see logs' }
    return 'Enabled · waiting for website tasks'
}
function Update-Display {
    $script:UpdatingUI = $true
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
    foreach ($agent in $Agents) {
        $ui = $AgentControls[$agent.agentKey]
        $enabled = @($config.enabledAgentKeys) -contains $agent.agentKey
        $ui.Check.Checked = $enabled
        $ui.State.Text = Get-AgentState $agent.agentKey $config $status
        $ui.State.ForeColor = if (-not $config.serviceEnabled -or -not $enabled) { [System.Drawing.Color]::DimGray } elseif ($status -and $status.activeAgentKeys -contains $agent.agentKey) { [System.Drawing.Color]::ForestGreen } else { [System.Drawing.Color]::DarkSlateBlue }
    }
    $script:UpdatingUI = $false
}

if ($AgentKey -and $EnableAgent) {
    Ensure-AgentEnabled $AgentKey
    Start-BackgroundService
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'TradeFlow Research Control Centre'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(900,720)
$form.MinimumSize = New-Object System.Drawing.Size(820,620)
$form.BackColor = [System.Drawing.Color]::FromArgb(246,248,250)
$form.Font = New-Object System.Drawing.Font('Segoe UI',9)
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi

$header = New-Object System.Windows.Forms.Panel
$header.Dock = 'Top'
$header.Height = 104
$header.BackColor = [System.Drawing.Color]::FromArgb(28,42,58)
$form.Controls.Add($header)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'TRADEFLOW  |  RESEARCH CONTROL CENTRE'
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold',16,[System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(22,16)
$title.AutoSize = $true
$header.Controls.Add($title)

$ServiceLabel = New-Object System.Windows.Forms.Label
$ServiceLabel.Text = 'Background service: checking…'
$ServiceLabel.ForeColor = [System.Drawing.Color]::FromArgb(225,232,239)
$ServiceLabel.Location = New-Object System.Drawing.Point(24,58)
$ServiceLabel.AutoSize = $true
$header.Controls.Add($ServiceLabel)

$buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonPanel.Dock = 'Top'
$buttonPanel.Height = 54
$buttonPanel.Padding = New-Object System.Windows.Forms.Padding(18,10,10,6)
$buttonPanel.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($buttonPanel)

$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = 'Start background service'
$startButton.Width = 190
$startButton.Height = 32
$startButton.FlatStyle = 'Flat'
$startButton.BackColor = [System.Drawing.Color]::FromArgb(33,112,82)
$startButton.ForeColor = [System.Drawing.Color]::White
$startButton.Add_Click({ try { Start-BackgroundService; Update-Display } catch { [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'TradeFlow') } }.GetNewClosure())
$buttonPanel.Controls.Add($startButton)

$stopButton = New-Object System.Windows.Forms.Button
$stopButton.Text = 'Stop after current task'
$stopButton.Width = 170
$stopButton.Height = 32
$stopButton.FlatStyle = 'Flat'
$stopButton.Add_Click({ Stop-BackgroundService; Update-Display }.GetNewClosure())
$buttonPanel.Controls.Add($stopButton)

$logsButton = New-Object System.Windows.Forms.Button
$logsButton.Text = 'Open logs'
$logsButton.Width = 100
$logsButton.Height = 32
$logsButton.Add_Click({ New-Item -ItemType Directory -Path $LogPath -Force | Out-Null; Invoke-Item $LogPath }.GetNewClosure())
$buttonPanel.Controls.Add($logsButton)

$note = New-Object System.Windows.Forms.Label
$note.Text = 'Enable the agents you want available. They wait quietly until matching work arrives from TradeFlow LIVE. Closing this window does not stop the background service.'
$note.Dock = 'Top'
$note.Height = 48
$note.Padding = New-Object System.Windows.Forms.Padding(22,12,20,8)
$note.BackColor = [System.Drawing.Color]::FromArgb(246,248,250)
$note.ForeColor = [System.Drawing.Color]::FromArgb(70,82,94)
$form.Controls.Add($note)

$cards = New-Object System.Windows.Forms.FlowLayoutPanel
$cards.Dock = 'Fill'
$cards.AutoScroll = $true
$cards.WrapContents = $true
$cards.Padding = New-Object System.Windows.Forms.Padding(14,8,14,14)
$cards.BackColor = [System.Drawing.Color]::FromArgb(246,248,250)
$form.Controls.Add($cards)

$AgentControls = @{}
foreach ($agent in $Agents) {
    $card = New-Object System.Windows.Forms.Panel
    $card.Width = 400
    $card.Height = 112
    $card.Margin = New-Object System.Windows.Forms.Padding(8)
    $card.Padding = New-Object System.Windows.Forms.Padding(12)
    $card.BackColor = [System.Drawing.Color]::White
    $card.BorderStyle = 'FixedSingle'

    $name = New-Object System.Windows.Forms.Label
    $name.Text = [string]$agent.label
    $name.Font = New-Object System.Drawing.Font('Segoe UI Semibold',11,[System.Drawing.FontStyle]::Bold)
    $name.Location = New-Object System.Drawing.Point(12,12)
    $name.AutoSize = $true
    $card.Controls.Add($name)

    $state = New-Object System.Windows.Forms.Label
    $state.Text = 'Checking…'
    $state.Location = New-Object System.Drawing.Point(12,43)
    $state.Width = 350
    $state.Height = 24
    $state.ForeColor = [System.Drawing.Color]::DarkSlateBlue
    $card.Controls.Add($state)

    $check = New-Object System.Windows.Forms.CheckBox
    $check.Text = 'Agent enabled'
    $check.Tag = [string]$agent.agentKey
    $check.Location = New-Object System.Drawing.Point(12,76)
    $check.AutoSize = $true
    $check.Add_CheckedChanged({
        param($sender,$eventArgs)
        if (-not $script:UpdatingUI -and $sender.Tag) {
            try { Set-AgentEnabled ([string]$sender.Tag) ([bool]$sender.Checked); Update-Display }
            catch { [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'TradeFlow') }
        }
    }.GetNewClosure())
    $card.Controls.Add($check)

    $cards.Controls.Add($card)
    $AgentControls[[string]$agent.agentKey] = @{ Check=$check; State=$state }
}

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 3000
$timer.Add_Tick({ Update-Display }.GetNewClosure())
$form.Add_Shown({ Update-Display; $timer.Start() }.GetNewClosure())
$form.Add_FormClosed({ $timer.Stop() }.GetNewClosure())
[void]$form.ShowDialog()
