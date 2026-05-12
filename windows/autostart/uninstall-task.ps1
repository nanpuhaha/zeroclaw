#Requires -Version 5.1
<#
.SYNOPSIS
    Removes the ZeroClawDaemon scheduled task.
.PARAMETER RemoveScript
    Also delete the deployed start-daemon.ps1 from ~/.zeroclaw/bin/.
.EXAMPLE
    .\uninstall-task.ps1
    .\uninstall-task.ps1 -RemoveScript
#>

param(
    [switch]$RemoveScript
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$taskName  = "ZeroClawDaemon"
$deployDir = "$env:USERPROFILE\.zeroclaw\bin"
$script    = "$deployDir\start-daemon.ps1"

# ── Stop running process ──────────────────────────────────────────────────────
$proc = Get-Process -Name "zeroclaw" -ErrorAction SilentlyContinue
if ($proc) {
    Write-Host "Stopping zeroclaw (PID $($proc.Id))..."
    Stop-Process -Id $proc.Id -Force
}

# ── Remove task ───────────────────────────────────────────────────────────────
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($task) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "Removed task: $taskName"
} else {
    Write-Host "Task not found: $taskName (already removed?)"
}

# ── Optionally remove deployed script ────────────────────────────────────────
if ($RemoveScript -and (Test-Path $script)) {
    Remove-Item $script -Force
    Write-Host "Removed: $script"
}

Write-Host "Done."
