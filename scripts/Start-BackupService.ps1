<#
.Description
This script contains all the logic needed to get the game files, archive them, and then move them to the backup location.
#>

$backupRoot = '/app/backups'
$workingRoot = '/app/working'
$logLocation = '/app/logs'

# To ensure consistency, we're creating variables for each game name
$gameName_7DTD = '7DTD'


# ================= FUNCTIONS =================

<#
.Description
Parses the game name onto the working folder
#>
Function Get-WorkingFolder([string]$gameName)
{
  Return (Join-Path $workingRoot $gameName)
} # function Get-WorkingFolder

<#
.Description
Parses the game name onto the working folder
#>
Function Get-BackupFolder([string]$gameName)
{
  Return (Join-Path $backupRoot $gameName)
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
Function Get-FilesFromFtpServer([string]$gameName, [string]$connectionString, [string]$remoteFolder)
{
  $workingFolder = (Get-WorkingFolder $gameName)
  
  Remove-WorkingFolder $gameName

  Write-Output "Creating working directory: $workingFolder"
  New-Item -Path $workingFolder -ItemType Directory

  # Same games need additional switches, such as folder exclusions
  $optionalSwitches = ''
  Switch ($gameName)
  {
    "$gameName_7DTD" { $optionalSwitches = '--reject-regex=\/Mods\/' }
    Default {Throw "Unknown game name passed to Get-FilesFromFtpServer"}
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
    Write-Output $backupFolder
    Write-Output "Pruning backups (if necessary) for $gameName to keep only the last $env:BACKUPS_MAX_COUNT"
    Get-ChildItem $backupFolder | Sort-Object CreationTime -desc | Select-Object -Skip $env:BACKUPS_MAX_COUNT | Remove-Item -Force -Verbose
  }
} # Function Resize-Backups

<#
.Description
Backup-GameFiles calls the various worker functions to download, zip, and rotate backups for each game server
#>
Function Backup-GameFiles([string]$gameName, [string]$connectionString, [string]$remoteFolder)
{
  Write-Output "============ Starting backup for $gameName ============"
  Get-FilesFromFtpServer $gameName $connectionString $remoteFolder
  New-Archive $gameName
  Copy-ArchiveToBackup $gameName
  Resize-Backups $gameName

  Write-Output "Performing cleanup"
  Remove-WorkingFolder $gameName

  Write-Output "============ Backup completed for $gameName ============"

} # function Backup-GameFiles

# ================= MAIN =================

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
$logFileName = "BackupService_Log_$((Get-Date).tostring("yyyy-MM-dd_HHmmss")).log"
$logFilePath = Join-Path $logLocation $logFileName
Start-Transcript -path $logFilePath -append

# If ([Environment]::GetEnvironmentVariable("GAME_$gameName_7DTD")) { Backup-Gamefiles "$gameName_7DTD" "$([Environment]::GetEnvironmentVariable("GAME_$gameName_7DTD"))" "/saves/" }
$games = (Get-Item -path Env:\GAME_*)
if ($games.Count -eq 0) 
{
  Write-Error "No game environment variables found. Please make sure you specify at least one variable that starts with GAME_"
  Exit 1
} # if ($games.Count -eq 0) 

Foreach ($game in $games)
{
  $name = ($game).Name
  $connectionString = ($game).Value
  Switch ($name)
  {
    "GAME_$gameName_7DTD" { Backup-Gamefiles "$gameName_7DTD" "$connectionString" "/saves/" }
    Default
    {
      Write-Error "The variable name $name is not recognized. If you believe this is in error, please open an issue on our GitHub page: https://github.com/DiceNinjaGaming/gportal-backup-docker"
    }
  } # Switch ($game.Name.Value)
} # Foreach ($game in $games)

Stop-Transcript