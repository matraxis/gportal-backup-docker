Write-Output "Cron Expression:$env:CRON_EXPRESSION"

# Update the cron job during startup
Out-File -FilePath ./timer.cron -InputObject "$env:CRON_EXPRESSION pwsh /scripts/Start-BackupService.ps1"
crontab timer.cron

# This is for testing purposes only
pwsh /scripts/Start-BackupService.ps1

Write-Output "Cron job is scheduled. You won't see any additional output on this screen until the container exits."
Write-Output "You can check the backup logs in /app/logs"
