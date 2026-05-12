# Windows Setup (nanpuhaha/zeroclaw)

Personal Windows-specific additions on the `windows/nanpuhaha` branch.

## Contents

- [Auto-Start (hidden background daemon)](../docs/book/src/setup/windows-autostart.md)
  — Run zeroclaw daemon at logon without a terminal window, no admin rights required.

## Scripts

| Script | Purpose |
|--------|---------|
| [`autostart/install-task.ps1`](autostart/install-task.ps1) | Register the Task Scheduler entry |
| [`autostart/uninstall-task.ps1`](autostart/uninstall-task.ps1) | Remove the task |
| [`autostart/start-daemon.ps1`](autostart/start-daemon.ps1) | Hidden-launch wrapper (deployed to `~\.zeroclaw\bin\`) |

## Quick start

```powershell
.\windows\autostart\install-task.ps1
Start-ScheduledTask -TaskName "ZeroClawDaemon"
```
