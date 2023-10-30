$path = "/scripts/helpers"
Get-ChildItem -Path $path -Filter *.ps1 | ForEach-Object { . $_.FullName }

$global:GameListFile = "/app/gamelist.csv"
$global:ConfigFile = "/app/config.csv"
$global:backupRoot = '/app/backups'
$global:workingRoot = '/app/working'
$global:logLocation = '/app/logs'