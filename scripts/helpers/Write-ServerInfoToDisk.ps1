<#
.Description
This script will get the list of game servers from the environment variables, parse their relevant information, and 
write the details out to a comma-delimited file.

This is necessary because the information is passed in via environment variables, which are not available to the
BackupService process(es) spawned by cron.
#>

# Importing classes from the module hasn't worked, so we import them separately
Get-ChildItem -Path /scripts/classes -Filter *.ps1 | ForEach-Object { . $_.FullName }

Function Write-ServerInfoToDisk
{
    $environment = (Get-Item -path Env:\GAME_*)
    if ($environment.Count -eq 0) 
    {
    Write-Error "No game environment variables found. Please make sure you specify at least one variable that starts with GAME_"
    Exit 1
    } # if ($games.Count -eq 0) 

    Write-Output "Parsing environment variables"
    Foreach ($game in $environment)
    {
        $name = ($game).Name
        $connectionString = ($game).Value
        Switch ($name)
        {
            # Please keep these in alphabetical order, it'll make it easier to update
            "GAME_7DTD" { $gamesList.Add([Game]@{"Name"="7DTD";"ConnectionString"="$connectionString";"RemoteFolder"="/saves/"}) }
            "GAME_ARK_SE" { $gamesList.Add([Game]@{"Name"="Ark_SE";"ConnectionString"="$connectionString";"RemoteFolder"="/ShooterGame/Saved/" }) }
            "GAME_ICARUS" { $gamesList.Add([Game]@{"Name"="Icarus";"ConnectionString"="$connectionString";"RemoteFolder"="/Icarus/Config/" }) }
            "GAME_VALHEIM" { $gamesList.Add([Game]@{"Name"="Valheim";"ConnectionString"="$connectionString";"RemoteFolder"="/save/" }) }
            Default
            {
            Write-Error "The variable name $name is not recognized. If you believe this is in error, please open an issue on our GitHub page: https://github.com/DiceNinjaGaming/gportal-backup-docker"
            }
        } # Switch ($game.Name.Value)
    } # Foreach ($game in $games)

    Write-Output "Writing game server info to file"
    $gamesList | Export-CSV -Path $global:GameListFile
} # Function Write-ServerInfoToDisk