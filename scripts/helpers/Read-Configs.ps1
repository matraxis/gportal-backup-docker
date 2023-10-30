<#
.Description
This script will read the configs, parse their relevant information, and return hashtable of objects with those details
#>

Get-ChildItem -Path /scripts/classes -Filter *.ps1 | ForEach-Object { . $_.FullName }

function Read-Configs
{
    Write-Output "Reading config info from file"
    $config = Import-CSV -Path $global:ConfigFile

    Return $config
} # function Get-GamesToBackup

