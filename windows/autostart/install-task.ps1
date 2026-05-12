#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the ZeroClawDaemon scheduled task for hidden background autostart.
.DESCRIPTION
    Copies start-daemon.ps1 to ~/.zeroclaw/bin/ and registers a Task Scheduler
    entry that launches zeroclaw daemon silently at user logon.
    Does NOT require administrator privileges.
.EXAMPLE
    .\install-task.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$taskName  = "ZeroClawDaemon"
$deployDir = "$env:USERPROFILE\.zeroclaw\bin"
$logDir    = "$env:USERPROFILE\.zeroclaw\logs"
$script    = "$deployDir\start-daemon.ps1"
$source    = Join-Path $PSScriptRoot "start-daemon.ps1"

# ── Create directories ────────────────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path $deployDir | Out-Null
New-Item -ItemType Directory -Force -Path $logDir    | Out-Null

# ── Copy launcher script ──────────────────────────────────────────────────────
Copy-Item -Path $source -Destination $script -Force
Write-Host "Copied start-daemon.ps1 -> $script"

# ── Remove existing task if present ──────────────────────────────────────────
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

# ── Register task ─────────────────────────────────────────────────────────────
$action = New-ScheduledTaskAction `
    -Execute    "powershell.exe" `
    -Argument   "-NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""

$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit      (New-TimeSpan -Hours 0) `
    -MultipleInstances       IgnoreNew `
    -StartWhenAvailable `
    -DontStopIfGoingOnBatteries `
    -AllowStartIfOnBatteries `
    -RestartCount            3 `
    -RestartInterval         (New-TimeSpan -Seconds 10)

$principal = New-ScheduledTaskPrincipal `
    -UserId    $env:USERNAME `
    -LogonType Interactive `
    -RunLevel  Limited

Register-ScheduledTask `
    -TaskName   $taskName `
    -Action     $action `
    -Trigger    $trigger `
    -Settings   $settings `
    -Principal  $principal `
    -Description "ZeroClaw daemon — hidden background launch at logon" `
    -Force | Out-Null

Write-Host "Registered task: $taskName"
Write-Host ""
Write-Host "To start now without rebooting:"
Write-Host "  Start-ScheduledTask -TaskName '$taskName'"
Write-Host ""
Write-Host "Logs:"
Write-Host "  stdout: $logDir\daemon.stdout.log"
Write-Host "  stderr: $logDir\daemon.stderr.log"
