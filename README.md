# gportal-backup-docker
A Docker container to back up G-Portal servers.

# Important folders
| Name | Description |
| - | - |
| /app/working | Working directory. This will get cleared out every run |
| /app/backups | Backup location. Will contain a sub-folder for each game. We recommend setting this volume to an easily accessible location for easy off-site backup or retrieval |
| /app/logs | Logs for the various processes |

# Environment Variables
| Name | Default | Description |
| ---------------- | ------- | ----------- |
| TZ | Etc/UTC | Time zone for the server. A full list can be [found here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
| FILE_UMASK | 022 | umask value to use for configs, backups, and server files. [This article](https://www.digitalocean.com/community/tutorials/linux-permissions-basics-and-how-to-use-umask-on-a-vps) has a good explanation on permissions and how the umask works
| CRON_EXPRESSION | 0 0 * * * | Cron Expression used to schedule the backups |
| BACKUPS_MAX_COUNT | 0 | Maximum number of backups to keep. 0 keeps all backups |
| BACKUPS_INTERVAL | 360 | Number of minutes between backups |

## Game Environment Variables
None of these variables have a default value, they must be explicitly set
| Name Description |
| ---------------- | ----------- |
| GAME_7DTD | 7 Days to Die |
| GAME_ARK_SE | Ark: Survival Evolved |