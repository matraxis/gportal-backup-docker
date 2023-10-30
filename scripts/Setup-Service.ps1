Import-Module /scripts/helpers

Write-Output "Writing setup info to disk"
Write-ServerInfoToDisk
Write-ConfigsToDisk

Write-Output "Setting up cron"
Write-Output "Cron Expression: $env:CRON_EXPRESSION"

# Update the cron job during startup
Out-File -FilePath ./backup.cron -InputObject "$env:CRON_EXPRESSION pwsh -File /scripts/Start-BackupService.ps1"

if ($env:ENABLE_LONGTERM_BACKUPS)
{
    Write-Output "Long-Term backups enabled, adding to cron file"
    Write-Output "Long-Term cron expression: $env:LONGTERM_CRON_EXPRESSION"
    Out-File -FilePath ./backup.cron -InputObject "$env:LONGTERM_CRON_EXPRESSION pwsh -File /scripts/Start-LongTermBackupService.ps1" -Append
}

if ($env:LOG_FILE_MAX_DAYS -gt 0)
{
    Write-Output "Log file maximum days is set to $env:LOG_FILE_MAX_DAYS"
    Write-Output "Adding log pruning job to run every day at midnight in cron"
    Out-File -FilePath ./backup.cron -InputObject "0 0 * * * pwsh -File /scripts/Resize-LogFiles.ps1" -Append
}

chmod 0644 ./backup.cron
crontab backup.cron

# This is for testing purposes only
If ($env:ISDEV)
{
    # pwsh /scripts/Start-BackupService.ps1
    # pwsh /scripts/Start-LongTermBackupService.ps1
    # pwsh /scripts/Resize-LogFiles.ps1
}

Write-Output "Cron job is scheduled. You won't see any additional output on this screen until the container exits or restarts cron"
Write-Output "You can check the backup logs in /app/logs"
Write-Output "Unfortunately, cron logs are unavailable."
