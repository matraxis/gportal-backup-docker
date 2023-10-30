<#
.Description
This script contains all the logic needed to copy the latest backup to long-term storage.
#>

# Importing classes from the module hasn't worked, so we import them separately
Get-ChildItem -Path /scripts/classes -Filter *.ps1 | ForEach-Object { . $_.FullName }
Import-Module /scripts/helpers

# ================= FUNCTIONS =================

Import-Module /scripts/helpers

Function Copy-LongTermBackups($game)
{
    $gameName = $game.Name
  Write-Output "============ Starting long-term backup for $gameName ============"
  
  $backupFolder = Get-BackupFolder $gameName
  $longTermFolder = Get-LongTermBackupFolder $gameName

  # First, make sure there's something to back up
  if (-not (Test-Path $backupFolder))
  {
    Write-Output "Backup folder for $gameName doesn't exist, skipping long-term backup for this game"
    Return
  }

  if (-not (Get-ChildItem $backupFolder))
  {
    Write-Output "Backup folder exists for $gameName, but there aren't any backups to copy for this game"
    Return
  }

  if (-not (Test-Path $longTermFolder))
  {
    Write-Output "Long-Term backup folder for $gameName doesn't exist, creating it now"
    New-Item -Path $longTermFolder -ItemType Directory
  }

  Write-Output "Copying the latest backup for $gameName to long-term storage"
  $latestFile = Get-ChildItem -Attributes !Directory $backupFolder | Sort-Object -Descending -Property LastWriteTime | Select-Object -First 1
  Copy-Item $latestFile -Destination $longTermFolder -Verbose

  if ($env:LONGTERM_BACKUPS_MAX_COUNT -gt 0)
  {
    Write-Output "Pruning long-term backups (if necessary) for $gameName to keep only the latest $env:LONGTERM_BACKUPS_MAX_COUNT"
    Get-ChildItem $backupFolder | Sort-Object CreationTime -desc | Select-Object -Skip $env:LONGTERM_BACKUPS_MAX_COUNT | Remove-Item -Force -Verbose
  }

  Write-Output "============ Long-term backup completed for $gameName ============"

} # function Backup-GameFiles

# ================= MAIN =================

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
$logFileName = "Long-TermBackupService_Log_$((Get-Date).tostring("yyyy-MM-dd_HHmmss")).log"
$logFilePath = Join-Path $Global:logRoot $logFileName
Start-Transcript -path $logFilePath -append

Set-Config

$games = Get-GamesToBackup

if ($games.Count -gt 0)
{
  # The count is always off by 1 when reading in the file
  Write-Output "Backing up $($games.Count -1) servers"
  Foreach ($game in $games)
  {
    # Only run if there is a valid game name
    if ($game.Name)
    {
        Copy-LongTermBackups $game
    }
  } # oreach ($game in $games)
} # if ($games.Count -gt 0)

Stop-Transcript