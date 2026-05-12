$bin    = "$env:USERPROFILE\.zeroclaw\bin\zeroclaw.exe"
$logOut = "$env:USERPROFILE\.zeroclaw\logs\daemon.stdout.log"
$logErr = "$env:USERPROFILE\.zeroclaw\logs\daemon.stderr.log"

if (-not (Get-Process -Name "zeroclaw" -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath $bin `
        -ArgumentList "daemon" `
        -WindowStyle Hidden `
        -RedirectStandardOutput $logOut `
        -RedirectStandardError $logErr
}
