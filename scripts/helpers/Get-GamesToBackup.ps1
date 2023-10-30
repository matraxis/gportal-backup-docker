<#
.Description
This script will get the list of game servers, parse their relevant information, and return an array of objects with those details
#>

Get-ChildItem -Path /scripts/classes -Filter *.ps1 | ForEach-Object { . $_.FullName }
$gamesList = [System.Collections.Generic.List[Game]]::new()

function Get-GamesToBackup
{
    Write-Output "Reading game server info from file"
    $gamesList = (Import-CSV -Path $global:GameListFile | Sort-Object -Property 'Name')

    Return $gamesList
} # function Get-GamesToBackup

