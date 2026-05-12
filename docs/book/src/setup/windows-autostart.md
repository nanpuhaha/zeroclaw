# Windows Auto-Start (Hidden Background Daemon)

This page covers running the zeroclaw daemon automatically at Windows logon
**without a visible terminal window**, using the Windows Task Scheduler.

> **When to use this instead of `zeroclaw service install`**
>
> `zeroclaw service install` is the recommended approach for most users but
> requires administrator privileges. The method below uses a user-scoped
> scheduled task — no elevation needed, no UAC prompt, no black console window.

---

## Prerequisites

- zeroclaw binary installed to `%USERPROFILE%\.zeroclaw\bin\zeroclaw.exe`
  (placed there by the zeroclaw installer or copied manually from a release build)
- PowerShell 5.1 or later (included in Windows 10/11)
- Execution policy allows local scripts:

  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
  ```

---

## Install

From the repo root on the `windows/nanpuhaha` branch (or wherever you cloned it):

```powershell
.\windows\autostart\install-task.ps1
```

What `install-task.ps1` does:

1. Copies `start-daemon.ps1` → `%USERPROFILE%\.zeroclaw\bin\start-daemon.ps1`
2. Registers a Task Scheduler entry named **ZeroClawDaemon** that triggers at logon
3. The task runs `powershell.exe -WindowStyle Hidden` so no window ever appears

To start the daemon immediately without logging out:

```powershell
Start-ScheduledTask -TaskName "ZeroClawDaemon"
```

Verify it is running:

```powershell
Get-Process zeroclaw
Invoke-WebRequest http://127.0.0.1:42617/health
```

---

## File layout

| File in repo | Deployed path | Purpose |
|---|---|---|
| `windows/autostart/start-daemon.ps1` | `~\.zeroclaw\bin\start-daemon.ps1` | Hidden-launch wrapper (source of truth) |
| `windows/autostart/install-task.ps1` | run once, not deployed | Registers the Task Scheduler entry |
| `windows/autostart/uninstall-task.ps1` | run once, not deployed | Removes the task |

---

## Log locations

| Stream | Path |
|--------|------|
| Standard output | `%USERPROFILE%\.zeroclaw\logs\daemon.stdout.log` |
| Standard error | `%USERPROFILE%\.zeroclaw\logs\daemon.stderr.log` |

---

## Binary path note

`start-daemon.ps1` launches `%USERPROFILE%\.zeroclaw\bin\zeroclaw.exe` — the
**installed release binary**.

If you are building from source and want to run the compiled binary instead,
edit the `$bin` variable in the deployed `start-daemon.ps1` to point at
`<repo>\target\release\zeroclaw.exe`.

---

## Updating the binary

Replace `%USERPROFILE%\.zeroclaw\bin\zeroclaw.exe` with the new release binary,
then restart the daemon:

```powershell
# Stop current instance
Stop-Process -Name zeroclaw -Force -ErrorAction SilentlyContinue

# Start fresh via the task
Start-ScheduledTask -TaskName "ZeroClawDaemon"
```

---

## Uninstall

```powershell
# Remove the task (keeps the deployed script)
.\windows\autostart\uninstall-task.ps1

# Remove task AND the deployed script
.\windows\autostart\uninstall-task.ps1 -RemoveScript
```

---

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Task exists but daemon not running | `Get-Content ~\.zeroclaw\logs\daemon.stderr.log \| Select -Last 20` |
| "execution of scripts is disabled" | `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned` |
| Port 42617 already in use | `netstat -ano \| findstr 42617` — another zeroclaw instance may be running |
| Task Scheduler error 0x1 | The `zeroclaw.exe` binary path in `start-daemon.ps1` may be wrong |
