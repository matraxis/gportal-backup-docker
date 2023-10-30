<#
.Description
This script contains all the logic needed to get the game files, archive them, and then move them to the backup location.
#>

# Importing classes from the module hasn't worked, so we import them separately
Get-ChildItem -Path /scripts/classes -Filter *.ps1 | ForEach-Object { . $_.FullName }
Import-Module /scripts/helpers

# ================= FUNCTIONS =================

<#
.Description
Parses the game name onto the working folder
#>
Function Get-WorkingFolder([string]$gameName)
{
  Return (Join-Path $Global:workingRoot $gameName)
} # function Get-WorkingFolder

<#
.Description
Removes the working folder for the specified game.
#>
Function Remove-WorkingFolder([string]$gameName)
{
  $workingFolder = (Get-WorkingFolder $gameName)
  if (Test-Path $workingFolder) 
  { 
    Write-Output "Removing working directory: $workingFolder"
    Remove-Item -LiteralPath $workingFolder -Force -Recurse
  } # if (Test-Path $workingFolder)
} # Function Remove-WorkingFolder

<#
.Description
Uses wget to download the files from the ftp server into the working directory
#>
Function Get-FilesFromFtpServer($game)
{
  $gameName = $game.Name
  $connectionString = $game.ConnectionString
  $remoteFolder = $game.RemoteFolder

  $workingFolder = (Get-WorkingFolder $gameName)
  
  Remove-WorkingFolder $gameName

  Write-Output "Creating working directory: $workingFolder"
  New-Item -Path $workingFolder -ItemType Directory

  # Same games need additional switches, such as folder exclusions
  $optionalSwitches = ''
  Switch ($gameName)
  {
    "7DTD" { $optionalSwitches = '--reject-regex=\/Mods\/' }
  } # Switch ($gameName)

  Write-Output "Getting files from ftp"
  If ($optionalSwitches) { Write-Output "Optional Switches: $optionalSwitches" }
  wget -nH -r -np -nv -R "index.html*" $optionalSwitches -P $workingFolder "$connectionString$remoteFolder"
} # Function GetFiles-FromFtpServer

<#
.Description
Creates the backup archive
#>
Function New-Archive([string]$gameName)
{
  $workingFolder = (Get-WorkingFolder $gameName)
  $archiveFile = (Join-Path $workingFolder "${gameName}-backup-$((Get-Date).tostring("yyyy-MM-dd_HHmmss")).zip")
  
  Write-Output "Creating new archive for $gameName"
  Write-Output "Archive Path: $archiveFile"
  7z a -bsp1 "$archiveFile" "$workingFolder"
} # Function Create-Archive

<#
.Description
Copies any .zip file in the working directory to the final backup directory
#>
Function Copy-ArchiveToBackup([string]$gameName)
{
  $backupFolder = Get-BackupFolder $gameName
  Write-Output "Backing up archives for $gameName"

  if (-not (Test-Path $backupFolder))
  {
    Write-Output "Backup folder for $gameName doesn't exist, creating it now: $backupFolder"
    New-Item -Path $backupFolder -ItemType Directory
  }

  $workingFolder = (Get-WorkingFolder $gameName)
  Copy-Item $workingFolder/*.zip -Destination $backupFolder -Verbose
} # Function Copy-ArchiveToBackup

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

<#
.Description
Backup-GameFiles calls the various worker functions to download, zip, and rotate backups for each game server
#>
Function Backup-GameFiles($game)
{
  Write-Output "============ Starting backup for $($game.Name) ============"
  
  Get-FilesFromFtpServer $game
  New-Archive $game.Name
  Copy-ArchiveToBackup $game.Name
  Resize-Backups $game.Name

  Write-Output "Performing cleanup"
  Remove-WorkingFolder $game.Name

  Write-Output "============ Backup completed for $($game.Name) ============"

} # function Backup-GameFiles

# ================= MAIN =================

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
$logFileName = "BackupService_Log_$((Get-Date).tostring("yyyy-MM-dd_HHmmss")).log"
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
      Backup-GameFiles $game
    }
  } # oreach ($game in $games)
} # if ($games.Count -gt 0)

Stop-Transcript