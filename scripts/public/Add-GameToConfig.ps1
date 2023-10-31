function Add-GameToConfig {
    [CmdletBinding()]
    param (
        # Name of the game to add.
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $GameName,

        # Max number of backups to keep.
        [Parameter(
            Mandatory = $true
        )]
        [int]
        $MaxNumberOfBackups,

        # Max number of long term backups to keep.
        [Parameter(
            Mandatory = $true
        )]
        [int]
        $MaxNumberOfLongTermBackups,

        # List of servers to backup.
        [Parameter(
            Mandatory = $false
        )]
        [string[]]
        $BackupServers
    )
    
    begin {
        class ConfigStructure {
            [string]$GameName
            [int]$MaxNumberOfBackups
            [int]$MaxNumberOfLongTermBackups
            [string]$BackupFolder
            [string]$longtermBackupFolder
            [string[]]$BackupServers

            ConfigStructure ($GameName, $MaxNumberOfBackups, $MaxNumberOfLongTermBackups, $BackupServers) {
                $this.GameName = $GameName
                $this.MaxNumberOfBackups = $MaxNumberOfBackups
                $this.MaxNumberOfLongTermBackups = $MaxNumberOfLongTermBackups
                $this.BackupFolder = "\app\$($GameName)"
                $this.longtermBackupFolder = "\appLTB\$($GameName)"
                $this.BackupServers = $BackupServers
            }
        }

        Write-Verbose -Message "Setting config file location."
        $Global:ConfigFilePath = Get-Item -Path .\configs\config.json
        Write-Verbose -Message "Getting configs from file."
        $ConfigFileData = @()
        $ConfigFileData += Get-Content -Path $Global:ConfigFilePath | ConvertFrom-Json
    }
    
    process {
        Write-Verbose -Message "Checking for game config first."
        if ($ConfigFileData | Where-Object -Property GameName -EQ $GameName) {
            Read-Host -Prompt "Configuration exists, overwrite? (Y/N)" -OutVariable Overwrite
            if ($Overwrite -ne "Y") {
                Write-Error -Exception "Game config exists" -Message "Game config exists. User cancelled." -Category OperationStopped -ErrorAction Stop
            }
            else {
                $ConfigFileData = $ConfigFileData | Where-Object -Property GameName -NE $GameName
            }
        }

        Write-Verbose -Message "Creating object for file."
        $ConfigToAdd = [ConfigStructure]::new($GameName, $MaxNumberOfBackups, $MaxNumberOfLongTermBackups, $BackupServers)

        Write-Verbose -Message "Adding Game Config for $GameName."
        $ConfigFileData += $ConfigToAdd

        Write-Verbose -Message "Outputing file."
        $ConfigFileData | ConvertTo-Json | Out-File -FilePath $Global:ConfigFilePath -Force
    }
    
    end {
        
    }
}