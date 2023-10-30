<#
.Description
This script will get the configuration settings and write them to disk.

This is necessary because the information is passed in via environment variables, which are not available to the
BackupService process(es) spawned by cron.
#>

# Importing classes from the module hasn't worked, so we import them separately
Get-ChildItem -Path /scripts/classes -Filter *.ps1 | ForEach-Object { . $_.FullName }

Function Write-ConfigsToDisk
{
    $config = @{}
    $config["BACKUPS_MAX_COUNT"] = $env:BACKUPS_MAX_COUNT

    Write-Output "Writing config info to file"
    $config | Export-CSV -Path $global:ConfigFile
} # Function Write-ConfigToDisk