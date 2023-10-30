<#
.Description
This script contains all the logic to prune the log files
#>

Import-Module /scripts/helpers

Set-Config

If ($env:LOG_FILE_MAX_DAYS -gt 0)
{
    Write-Output "Pruning log files (if necessary) to remove all logs older than $env:LOG_FILE_MAX_DAYS days"
    $limit = (Get-Date).AddDays(-$env:LOG_FILE_MAX_DAYS)
    Get-ChildItem $Global:logRoot | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force -Verbose
}
