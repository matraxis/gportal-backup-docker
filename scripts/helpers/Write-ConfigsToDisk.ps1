<#
.Description
This script will get the configuration settings and write them to disk.

This is necessary because the information is passed in via environment variables, which are not available to the
BackupService process(es) spawned by cron.
#>

Function Write-ConfigsToDisk
{
    $config = @{}
    $config.Add("BACKUPS_MAX_COUNT", $env:BACKUPS_MAX_COUNT)
    $config.Add("LONGTERM_BACKUPS_MAX_COUNT", $env:LONGTERM_BACKUPS_MAX_COUNT)
    # $config.Add("LOG_FILE_MAX_DAYS", $env:LOG_FILE_MAX_DAYS)

    Write-Output "Writing config info to file"
    $config | Export-CSV -Path $global:ConfigFile
} # Function Write-ConfigToDisk