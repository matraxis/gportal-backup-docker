Import-Module /scripts/helpers

Write-Output "Writing game info to disk"
Write-ServerInfoToDisk

Write-Output "Setting up cron"
Write-Output "Cron Expression: $env:CRON_EXPRESSION"

# Update the cron job during startup
Out-File -FilePath ./backup.cron -InputObject "$env:CRON_EXPRESSION pwsh -File /scripts/Start-BackupService.ps1"
chmod 0644 ./backup.cron
crontab backup.cron

# This is for testing purposes only
If ($env:ISDEV)
{
    pwsh /scripts/Start-BackupService.ps1
}

Write-Output "Cron job is scheduled. You won't see any additional output on this screen until the container exits or restarts cron"
Write-Output "You can check the backup logs in /app/logs"
Write-Output "Unfortunately, cron logs are unavailable."
