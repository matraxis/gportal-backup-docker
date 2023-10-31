$Scripts = Get-ChildItem -Path .\scripts\public -Filter *.ps1

foreach ($Script in $Scripts) {
    Write-Host "Importing $($Script.Name)"
    . $Script.FullName
}

Import-Module .\scripts\GlobalConfigs.ps1 -Force