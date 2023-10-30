$path = "/scripts/helpers"
Get-ChildItem -Path $path -Filter *.ps1 | ForEach-Object { . $_.FullName }

# ================= VARIABLES =================
$global:GameListFile = "/app/gamelist.csv"
$global:ConfigFile = "/app/config.csv"
$global:backupRoot = '/app/backups'
$global:workingRoot = '/app/working'
$global:logRoot = '/app/logs'

# ================= FUNCTIONS =================

<#
.Description
Parses the game name onto the backup folder
#>
Function Get-BackupFolder([string]$gameName)
{
  Return (Join-Path $Global:backupRoot $gameName)
} # function Get-BackupFolder

<#
.Description
Parses the game name onto the long-term backup folder
#>
Function Get-LongTermBackupFolder([string]$gameName)
{
  Return ([IO.Path]::Combine("$Global:backupRoot", 'Long-TermBackups', "$gameName"))
} # function Get-LongTermBackupFolder

<#
.Description
Sets up the environment variables after reading them from disk
#>
Function Set-Config
{
  $config = Read-Configs

  $env:BACKUPS_MAX_COUNT = $config["BACKUPS_MAX_COUNT"]
  $env:LONGTERM_BACKUPS_MAX_COUNT = $config["LONGTERM_BACKUPS_MAX_COUNT"]
} # Function Set-Config

# ================= MAIN =================
