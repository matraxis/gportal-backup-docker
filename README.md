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
| CRON_EXPRESSION | 0 0 * * * | Cron expression used to schedule the backups. Defaults to midnight every day. You can use [this site](https://crontab.guru/#0_0_*_*_*) to easily create the expression. |
| BACKUPS_MAX_COUNT | 7 | Maximum number of backups to keep. 0 keeps all backups |
| ENABLE_LONGTERM_BACKUPS | False | Enables a long-term backup that runs less often. It will take the latest backup at the time it runs and move it to a special folder. This is intended to be able to keep a weekly backup in case the server is idle for long periods and/or to keep snapshots of progress |
| LONGTERM_CRON_EXPRESSION | 0 2 * * 1 | Cron expression used to schedule the long-term backups. Defaults to 2am every Monday. You can use [this site](https://crontab.guru/#0_2_*_*_1) to easily create the expression. |
| LONGTERM_BACKUPS_MAX_COUNT | 0 | Maximum number of long-term backups to keep. 0 keeps all backups |
| LOG_FILE_MAX_DAYS | 30 | Maximum number of days to keep log files. Any files older than this many days will be deleted. 0 keeps all log files |

## Game Environment Variables
None of these variables have a default value, they must be explicitly set
| Name Description |
| ---------------- | ----------- |
| GAME_7DTD | 7 Days to Die |
| GAME_ARK_SE | Ark: Survival Evolved |
| GAME_ICARUS | Icarus |
| GAME_VALHEIM | Valheim |