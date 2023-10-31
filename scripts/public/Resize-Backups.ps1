<#
.Description
Prunes the backup folder so the maximum backups don't exceed the set limit
#>
Function Resize-Backups([string]$gameName)
{
  If ($env:BACKUPS_MAX_COUNT -GT 0)
  {
    $backupFolder = Get-BackupFolder $gameName
    Write-Output "Pruning backups (if necessary) for $gameName to keep only the latest $env:BACKUPS_MAX_COUNT"
    Get-ChildItem $backupFolder | Sort-Object CreationTime -desc | Select-Object -Skip $env:BACKUPS_MAX_COUNT | Remove-Item -Force -Verbose
  }
  else {
    Write-Output "Keeping all backups"
  }
} # Function Resize-Backups