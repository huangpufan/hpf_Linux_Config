[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('open', 'close', 'probe')]
    [string]$Action,

    [string]$Url = '',
    [string]$SessionId = '',

    [ValidateRange(20, 80)]
    [int]$LeftPercent = 55
)

$ErrorActionPreference = 'Stop'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class MarkdownReadingNative {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT {
        public int X;
        public int Y;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct WINDOWPLACEMENT {
        public int length;
        public int flags;
        public int showCmd;
        public POINT ptMinPosition;
        public POINT ptMaxPosition;
        public RECT rcNormalPosition;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public struct MONITORINFO {
        public int cbSize;
        public RECT rcMonitor;
        public RECT rcWork;
        public int dwFlags;
    }

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool IsWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int GetWindowTextLength(IntPtr hWnd);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int GetClassName(IntPtr hWnd, StringBuilder className, int count);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

    [DllImport("user32.dll")]
    public static extern bool GetWindowPlacement(IntPtr hWnd, ref WINDOWPLACEMENT placement);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPlacement(IntPtr hWnd, ref WINDOWPLACEMENT placement);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int command);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(
        IntPtr hWnd,
        IntPtr insertAfter,
        int x,
        int y,
        int width,
        int height,
        uint flags
    );

    [DllImport("user32.dll")]
    public static extern IntPtr MonitorFromWindow(IntPtr hWnd, uint flags);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern bool GetMonitorInfo(IntPtr monitor, ref MONITORINFO info);

    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hWnd, uint message, IntPtr wParam, IntPtr lParam);
}
'@

function Convert-Rect {
    param([MarkdownReadingNative+RECT]$Rect)

    return [ordered]@{
        x = $Rect.Left
        y = $Rect.Top
        width = $Rect.Right - $Rect.Left
        height = $Rect.Bottom - $Rect.Top
        left = $Rect.Left
        top = $Rect.Top
        right = $Rect.Right
        bottom = $Rect.Bottom
    }
}

function Get-WindowRecord {
    param([IntPtr]$Handle)

    if ($Handle -eq [IntPtr]::Zero -or -not [MarkdownReadingNative]::IsWindow($Handle)) {
        return $null
    }

    $processId = [uint32]0
    [void][MarkdownReadingNative]::GetWindowThreadProcessId($Handle, [ref]$processId)
    try {
        $process = Get-Process -Id $processId -ErrorAction Stop
    }
    catch {
        return $null
    }

    $titleLength = [MarkdownReadingNative]::GetWindowTextLength($Handle)
    $title = New-Object System.Text.StringBuilder ($titleLength + 1)
    [void][MarkdownReadingNative]::GetWindowText($Handle, $title, $title.Capacity)

    $className = New-Object System.Text.StringBuilder 256
    [void][MarkdownReadingNative]::GetClassName($Handle, $className, $className.Capacity)

    $rect = New-Object MarkdownReadingNative+RECT
    [void][MarkdownReadingNative]::GetWindowRect($Handle, [ref]$rect)

    return [pscustomobject]@{
        handle = $Handle.ToInt64()
        processId = [int]$processId
        processName = $process.ProcessName
        title = $title.ToString()
        className = $className.ToString()
        rect = Convert-Rect $rect
    }
}

function Get-TopLevelWindows {
    $handles = New-Object 'System.Collections.Generic.List[System.IntPtr]'
    $callback = [MarkdownReadingNative+EnumWindowsProc]{
        param([IntPtr]$Handle, [IntPtr]$Parameter)
        if ([MarkdownReadingNative]::IsWindowVisible($Handle)) {
            $handles.Add($Handle)
        }
        return $true
    }
    [void][MarkdownReadingNative]::EnumWindows($callback, [IntPtr]::Zero)

    $windows = @()
    foreach ($handle in $handles) {
        $record = Get-WindowRecord $handle
        if ($null -ne $record) {
            $windows += $record
        }
    }
    return $windows
}

function Test-TerminalWindow {
    param($Window)

    return $null -ne $Window -and (
        $Window.processName -eq 'WindowsTerminal' -or
        $Window.className -eq 'CASCADIA_HOSTING_WINDOW_CLASS'
    )
}

function Get-TerminalWindow {
    param([bool]$StrictForeground)

    $foreground = Get-WindowRecord ([MarkdownReadingNative]::GetForegroundWindow())
    if (Test-TerminalWindow $foreground) {
        return $foreground
    }
    if ($StrictForeground) {
        $name = if ($null -eq $foreground) { '<unknown>' } else { $foreground.processName }
        throw "The foreground window is not Windows Terminal (found: $name)."
    }

    $terminal = Get-TopLevelWindows |
        Where-Object { Test-TerminalWindow $_ } |
        Select-Object -First 1
    if ($null -eq $terminal) {
        throw 'No visible Windows Terminal window was found.'
    }
    return $terminal
}

function Get-MonitorLayout {
    param([IntPtr]$WindowHandle)

    $monitor = [MarkdownReadingNative]::MonitorFromWindow($WindowHandle, 2)
    if ($monitor -eq [IntPtr]::Zero) {
        throw 'Unable to find the monitor for Windows Terminal.'
    }

    $info = New-Object MarkdownReadingNative+MONITORINFO
    $info.cbSize = [Runtime.InteropServices.Marshal]::SizeOf($info)
    if (-not [MarkdownReadingNative]::GetMonitorInfo($monitor, [ref]$info)) {
        throw 'Unable to read the monitor work area.'
    }

    $workWidth = $info.rcWork.Right - $info.rcWork.Left
    $workHeight = $info.rcWork.Bottom - $info.rcWork.Top
    $leftWidth = [int][Math]::Round($workWidth * $LeftPercent / 100.0)
    $rightWidth = $workWidth - $leftWidth

    return [pscustomobject]@{
        monitor = Convert-Rect $info.rcMonitor
        workArea = Convert-Rect $info.rcWork
        left = [ordered]@{
            x = $info.rcWork.Left
            y = $info.rcWork.Top
            width = $leftWidth
            height = $workHeight
            left = $info.rcWork.Left
            top = $info.rcWork.Top
            right = $info.rcWork.Left + $leftWidth
            bottom = $info.rcWork.Bottom
        }
        right = [ordered]@{
            x = $info.rcWork.Left + $leftWidth
            y = $info.rcWork.Top
            width = $rightWidth
            height = $workHeight
            left = $info.rcWork.Left + $leftWidth
            top = $info.rcWork.Top
            right = $info.rcWork.Right
            bottom = $info.rcWork.Bottom
        }
    }
}

function Get-DefaultBrowser {
    $choicePath = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice'
    $choice = Get-ItemProperty -LiteralPath $choicePath -ErrorAction Stop
    $programId = [string]$choice.ProgId
    if ([string]::IsNullOrWhiteSpace($programId)) {
        throw 'Windows has no default HTTPS browser association.'
    }

    $commandKey = Get-Item -LiteralPath "Registry::HKEY_CLASSES_ROOT\$programId\shell\open\command" -ErrorAction Stop
    $openCommand = [string]$commandKey.GetValue('')
    $executable = $null
    if ($openCommand -match '^\s*"([^"]+)"') {
        $executable = $Matches[1]
    }
    elseif ($openCommand -match '^\s*([^\s]+)') {
        $executable = $Matches[1]
    }
    if ($executable) {
        $executable = [Environment]::ExpandEnvironmentVariables($executable)
        if (-not (Test-Path -LiteralPath $executable)) {
            $executable = $null
        }
    }

    $processName = if ($executable) { [IO.Path]::GetFileNameWithoutExtension($executable) } else { $null }
    $launchMode = switch -Regex ($processName) {
        '^(msedge|chrome|brave|vivaldi|opera)$' { 'chromium-app'; break }
        '^firefox$' { 'firefox-window'; break }
        default { if ($executable) { 'executable' } else { 'shell' } }
    }

    return [pscustomobject]@{
        name = if ($processName) { "System default ($processName)" } else { 'System default browser' }
        processName = $processName
        path = $executable
        programId = $programId
        launchMode = $launchMode
    }
}

function Get-StatePath {
    if ([string]::IsNullOrWhiteSpace($SessionId)) {
        throw 'SessionId is required for open and close actions.'
    }
    $safeSession = $SessionId -replace '[^A-Za-z0-9_.-]', '_'
    return Join-Path ([IO.Path]::GetTempPath()) "hpf-markdown-reading-$safeSession.json"
}

function Read-State {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
        return $null
    }
}

function Write-State {
    param([string]$Path, $State)

    $temporary = "$Path.$PID.tmp"
    $State | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $temporary -Encoding UTF8
    Move-Item -LiteralPath $temporary -Destination $Path -Force
}

function Get-Placement {
    param([IntPtr]$Handle)

    $placement = New-Object MarkdownReadingNative+WINDOWPLACEMENT
    $placement.length = [Runtime.InteropServices.Marshal]::SizeOf($placement)
    if (-not [MarkdownReadingNative]::GetWindowPlacement($Handle, [ref]$placement)) {
        throw 'Unable to capture the Windows Terminal placement.'
    }
    return [ordered]@{
        flags = $placement.flags
        showCmd = $placement.showCmd
        minX = $placement.ptMinPosition.X
        minY = $placement.ptMinPosition.Y
        maxX = $placement.ptMaxPosition.X
        maxY = $placement.ptMaxPosition.Y
        normalLeft = $placement.rcNormalPosition.Left
        normalTop = $placement.rcNormalPosition.Top
        normalRight = $placement.rcNormalPosition.Right
        normalBottom = $placement.rcNormalPosition.Bottom
    }
}

function Restore-Terminal {
    param($State)

    if ($null -eq $State -or -not [MarkdownReadingNative]::IsWindow([IntPtr][int64]$State.terminalHandle)) {
        return
    }

    $placement = New-Object MarkdownReadingNative+WINDOWPLACEMENT
    $placement.length = [Runtime.InteropServices.Marshal]::SizeOf($placement)
    $placement.flags = [int]$State.placement.flags
    $placement.showCmd = [int]$State.placement.showCmd

    $minPoint = New-Object MarkdownReadingNative+POINT
    $minPoint.X = [int]$State.placement.minX
    $minPoint.Y = [int]$State.placement.minY
    $placement.ptMinPosition = $minPoint

    $maxPoint = New-Object MarkdownReadingNative+POINT
    $maxPoint.X = [int]$State.placement.maxX
    $maxPoint.Y = [int]$State.placement.maxY
    $placement.ptMaxPosition = $maxPoint

    $normalRect = New-Object MarkdownReadingNative+RECT
    $normalRect.Left = [int]$State.placement.normalLeft
    $normalRect.Top = [int]$State.placement.normalTop
    $normalRect.Right = [int]$State.placement.normalRight
    $normalRect.Bottom = [int]$State.placement.normalBottom
    $placement.rcNormalPosition = $normalRect

    [void][MarkdownReadingNative]::ShowWindow([IntPtr][int64]$State.terminalHandle, 9)
    [void][MarkdownReadingNative]::SetWindowPlacement([IntPtr][int64]$State.terminalHandle, [ref]$placement)
}

function Set-WindowRectangle {
    param([IntPtr]$Handle, $Rectangle)

    [void][MarkdownReadingNative]::ShowWindow($Handle, 9)
    if (-not [MarkdownReadingNative]::SetWindowPos(
        $Handle,
        [IntPtr]::Zero,
        [int]$Rectangle.x,
        [int]$Rectangle.y,
        [int]$Rectangle.width,
        [int]$Rectangle.height,
        0x0040
    )) {
        throw "Unable to position window handle $($Handle.ToInt64())."
    }
}

function Close-BrowserWindow {
    param([int64]$Handle)

    if ($Handle -ne 0 -and [MarkdownReadingNative]::IsWindow([IntPtr]$Handle)) {
        [void][MarkdownReadingNative]::PostMessage([IntPtr]$Handle, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
    }
}

function Close-RecordedState {
    param($State, [string]$Path)

    if ($null -ne $State) {
        Close-BrowserWindow ([int64]$State.browserHandle)
        Restore-Terminal $State
    }
    if ($Path) {
        Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    }
}

function Wait-NewBrowserWindow {
    param($Browser, $BeforeHandles)

    $deadline = [DateTime]::UtcNow.AddSeconds(8)
    do {
        $candidates = @(Get-TopLevelWindows | Where-Object {
            (-not $Browser.processName -or $_.processName -eq $Browser.processName) -and
            (
                -not $BeforeHandles.ContainsKey([string]$_.handle) -or
                ($_.title -like 'Markdown Reading -*' -and $BeforeHandles[[string]$_.handle] -ne $_.title)
            )
        })
        if ($candidates.Count -gt 0) {
            return $candidates |
                Sort-Object { $_.rect.width * $_.rect.height } -Descending |
                Select-Object -First 1
        }
        Start-Sleep -Milliseconds 75
    } while ([DateTime]::UtcNow -lt $deadline)

    throw "Timed out waiting for the new $($Browser.name) app window."
}

function Wait-BrowserReady {
    param([int64]$Handle)

    $deadline = [DateTime]::UtcNow.AddMilliseconds(1500)
    do {
        $window = Get-WindowRecord ([IntPtr]$Handle)
        if ($null -eq $window) {
            throw 'The default browser window closed before layout was applied.'
        }
        if ($window.title -like 'Markdown Reading -*') {
            return
        }
        Start-Sleep -Milliseconds 50
    } while ([DateTime]::UtcNow -lt $deadline)
}

function Start-DefaultBrowserWindow {
    param($Browser, [string]$TargetUrl)

    switch ($Browser.launchMode) {
        'chromium-app' {
            [void](Start-Process -FilePath $Browser.path -ArgumentList @('--new-window', "--app=$TargetUrl") -PassThru)
        }
        'firefox-window' {
            [void](Start-Process -FilePath $Browser.path -ArgumentList @('-new-window', $TargetUrl) -PassThru)
        }
        'executable' {
            [void](Start-Process -FilePath $Browser.path -ArgumentList @($TargetUrl) -PassThru)
        }
        default {
            [void](Start-Process -FilePath $TargetUrl -PassThru)
        }
    }
}

function Invoke-Probe {
    $terminal = Get-TerminalWindow $false
    $layout = Get-MonitorLayout ([IntPtr][int64]$terminal.handle)
    $browser = Get-DefaultBrowser
    $browserWindows = Get-TopLevelWindows | Where-Object { $_.processName -eq $browser.processName }
    $active = $null
    if (-not [string]::IsNullOrWhiteSpace($SessionId)) {
        $statePath = Get-StatePath
        $state = Read-State $statePath
        if ($null -ne $state) {
            $activeTerminal = Get-WindowRecord ([IntPtr][int64]$state.terminalHandle)
            $activeBrowser = Get-WindowRecord ([IntPtr][int64]$state.browserHandle)
            $active = [ordered]@{
                sessionId = $SessionId
                terminal = $activeTerminal
                browser = $activeBrowser
                matchesExpected = (
                    $null -ne $activeTerminal -and
                    $null -ne $activeBrowser -and
                    $activeTerminal.rect.left -eq $layout.left.left -and
                    $activeTerminal.rect.top -eq $layout.left.top -and
                    $activeTerminal.rect.right -eq $layout.left.right -and
                    $activeTerminal.rect.bottom -eq $layout.left.bottom -and
                    $activeBrowser.rect.left -eq $layout.right.left -and
                    $activeBrowser.rect.top -eq $layout.right.top -and
                    $activeBrowser.rect.right -eq $layout.right.right -and
                    $activeBrowser.rect.bottom -eq $layout.right.bottom
                )
            }
        }
    }

    [ordered]@{
        status = 'probe'
        terminal = $terminal
        browser = [ordered]@{
            name = $browser.name
            path = $browser.path
            programId = $browser.programId
            launchMode = $browser.launchMode
            windows = @($browserWindows)
        }
        monitor = $layout.monitor
        workArea = $layout.workArea
        left = $layout.left
        right = $layout.right
        active = $active
        geometry = [ordered]@{
            noOverlap = $layout.left.right -eq $layout.right.left
            coversWorkArea = (
                $layout.left.left -eq $layout.workArea.left -and
                $layout.right.right -eq $layout.workArea.right -and
                ($layout.left.width + $layout.right.width) -eq $layout.workArea.width
            )
        }
    } | ConvertTo-Json -Depth 8 -Compress
}

function Invoke-Close {
    $statePath = Get-StatePath
    $state = Read-State $statePath
    if ($null -eq $state) {
        [ordered]@{ status = 'already-closed'; sessionId = $SessionId } | ConvertTo-Json -Compress
        return
    }

    Close-RecordedState $state $statePath
    [ordered]@{ status = 'closed'; sessionId = $SessionId } | ConvertTo-Json -Compress
}

function Invoke-Open {
    if ([string]::IsNullOrWhiteSpace($Url)) {
        throw 'Url is required for the open action.'
    }

    $statePath = Get-StatePath
    $existing = Read-State $statePath
    if ($null -ne $existing) {
        $browserAlive = $existing.browserHandle -and [MarkdownReadingNative]::IsWindow([IntPtr][int64]$existing.browserHandle)
        $terminalAlive = [MarkdownReadingNative]::IsWindow([IntPtr][int64]$existing.terminalHandle)
        $createdAt = [DateTime]::MinValue
        $hasCreatedAt = [DateTime]::TryParse([string]$existing.createdAt, [ref]$createdAt)
        $recentlyOpening = (
            [int64]$existing.browserHandle -eq 0 -and
            $hasCreatedAt -and
            $createdAt.ToUniversalTime() -gt [DateTime]::UtcNow.AddSeconds(-30)
        )
        if ($terminalAlive -and ($browserAlive -or $recentlyOpening)) {
            [ordered]@{ status = 'busy'; sessionId = $SessionId } | ConvertTo-Json -Compress
            return
        }
        Close-RecordedState $existing $statePath
    }

    $terminal = Get-TerminalWindow $true
    $terminalHandle = [IntPtr][int64]$terminal.handle
    $layout = Get-MonitorLayout $terminalHandle
    $browser = Get-DefaultBrowser

    $token = [Guid]::NewGuid().ToString('N')
    $state = [ordered]@{
        version = 1
        token = $token
        sessionId = $SessionId
        terminalHandle = $terminal.handle
        browserHandle = 0
        browserProcessId = 0
        browserName = $browser.name
        placement = Get-Placement $terminalHandle
        createdAt = [DateTime]::UtcNow.ToString('o')
    }

    $newBrowser = $null
    try {
        Write-State $statePath $state

        $beforeHandles = @{}
        Get-TopLevelWindows | ForEach-Object { $beforeHandles[[string]$_.handle] = $_.title }

        Start-DefaultBrowserWindow $browser $Url
        $newBrowser = Wait-NewBrowserWindow $browser $beforeHandles

        $current = Read-State $statePath
        if ($null -eq $current -or $current.token -ne $token) {
            Close-BrowserWindow ([int64]$newBrowser.handle)
            [ordered]@{ status = 'cancelled'; sessionId = $SessionId } | ConvertTo-Json -Compress
            return
        }

        $state.browserHandle = $newBrowser.handle
        $state.browserProcessId = $newBrowser.processId
        Write-State $statePath $state

        [void][MarkdownReadingNative]::ShowWindow([IntPtr][int64]$newBrowser.handle, 6)
        Wait-BrowserReady ([int64]$newBrowser.handle)

        $current = Read-State $statePath
        if ($null -eq $current -or $current.token -ne $token) {
            Close-BrowserWindow ([int64]$newBrowser.handle)
            [ordered]@{ status = 'cancelled'; sessionId = $SessionId } | ConvertTo-Json -Compress
            return
        }

        Set-WindowRectangle $terminalHandle $layout.left
        Set-WindowRectangle ([IntPtr][int64]$newBrowser.handle) $layout.right

        $current = Read-State $statePath
        if ($null -eq $current -or $current.token -ne $token) {
            Close-BrowserWindow ([int64]$newBrowser.handle)
            Restore-Terminal $state
            [ordered]@{ status = 'cancelled'; sessionId = $SessionId } | ConvertTo-Json -Compress
            return
        }

        [ordered]@{
            status = 'opened'
            sessionId = $SessionId
            terminalHandle = $terminal.handle
            browserHandle = $newBrowser.handle
            browser = $browser.name
            left = $layout.left
            right = $layout.right
        } | ConvertTo-Json -Depth 6 -Compress
    }
    catch {
        if ($null -ne $newBrowser) {
            Close-BrowserWindow ([int64]$newBrowser.handle)
        }
        Restore-Terminal $state
        Remove-Item -LiteralPath $statePath -Force -ErrorAction SilentlyContinue
        throw
    }
}

try {
    switch ($Action) {
        'probe' { Invoke-Probe }
        'close' { Invoke-Close }
        'open' { Invoke-Open }
    }
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
