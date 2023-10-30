<center><img src="https://cdn.shopify.com/s/files/1/0816/1342/2908/files/Combo_Mark_Logo_-_Maroon_BG.svg" width="200" height="200"></center>

# gportal-backup-docker
This is an easy-to-use Docker container that will back up G-Portal servers locally. G-Portal does not offer any automated methods of backing up your game servers, and their manual process doesn't allow for offsite backups.

# Why Docker?
It is possible, and in a lot of cases, preferable, to just set up a scheduled script somewhere to run and do the backups for you. The reason we chose to do this in a Docker container is
1. Portability - It's easy to move the container around as your needs change and expand
2. Installation and configuration is simple
3. Anybody can run the exact same setup whether they use Windows, Linux, or even a Raspberry Pi

# Important folders
| Name | Description |
| - | - |
| /app/working | Working directory. This will get cleared out every run |
| /app/backups | Backup location. Will contain a sub-folder for each game. We recommend setting this volume to an easily accessible location for easy off-site backup and retrieval |
| /app/logs | Logs for the various processes |

# Environment Variables
| Name | Default | Description |
| ---------------- | ------- | ----------- |
| TZ | Etc/UTC | Time zone for the server. A full list can be [found here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
| FILE_UMASK | 022 | umask value to use for configs, backups, and server files. [This article](https://www.digitalocean.com/community/tutorials/linux-permissions-basics-and-how-to-use-umask-on-a-vps) has a good explanation on permissions and how the umask works
| CRON_EXPRESSION | 0 0 * * * | Cron expression used to schedule the backups. Defaults to midnight every day. You can use [this site](https://crontab.guru/#0_0_*_*_*) to easily create the expression if you want to change it |
| BACKUPS_MAX_COUNT | 7 | Maximum number of backups to keep. 0 keeps all backups |
| ENABLE_LONGTERM_BACKUPS | False | Enables a long-term backup that runs less often. See full explanation below |
| LONGTERM_CRON_EXPRESSION | 0 2 * * 1 | Cron expression used to schedule the long-term backups. Defaults to 2am every Monday. You can use [this site](https://crontab.guru/#0_2_*_*_1) to easily create the expression. |
| LONGTERM_BACKUPS_MAX_COUNT | 0 | Maximum number of long-term backups to keep. 0 keeps all backups |
| LOG_FILE_MAX_DAYS | 30 | Maximum number of days to keep log files. Any files older than this many days will be deleted. 0 keeps all log files |

## Game Environment Variables
None of these variables have a default value, they must be explicitly set. In order to back up the server, you need to set the environment variable with the ftp information.

Variables without a value are ignored.

| Variable Name | Game |
| ---------------- | ----------- |
| GAME_7DTD | 7 Days to Die |
| GAME_ARK_SE | Ark: Survival Evolved |
| GAME_ICARUS | Icarus |
| GAME_VALHEIM | Valheim |

### To find the FTP Information
1. Log in to your G-Portal admin
2. Navigate to the Status page for the server
3. Scroll down to the `Access Data` section
4. Right-click on the IP address link to the right of "Hostname"
5. Click `Copy Link Address`
6. Paste the address into the environment variable (It should look like this: `ftp://gpftp051714851268441:ktV1AGH$@158.202.54.162:78607/`

<img src="docs/images/G-Portal_FTP_Info.png">

# Sample Docker Compose File
**NOTE:** In the sample docker compose, we give the volumes explicit local paths. You can use the built-in volume manager if you'd like. We prefer having easy access to the volumes from the commandline, and have `/mnt/backups` is an NFS mount to our file server so we don't have to worry about using rsync or ftp to get the backups to their final resting place.

```
version: "3"
name: gportal-backup

services: 
  gportal-backup: 
    image: diceninjagaming/gportal-backup:latest
    container_name: gportal-backup
    volumes: 
      - /mnt/backups/gportal:/app/backups
      - /container-data/gportal:/app
    environment:
      TZ: "America/New_York"
      ENABLE_LONGTERM_BACKUPS: True
      GAME_7DTD: ftp://gpftp051714851268441:ktV1AGH$@158.202.54.162:78607/
      GAME_ARK_SE: ftp://gpftp051714851268441:ktV1AGH$@158.202.54.162:78607/
      GAME_ICARUS: ftp://gpftp051714851268441:ktV1AGH$@158.202.54.162:78607/
      GAME_VALHEIM: ftp://gpftp051714851268441:ktV1AGH$@158.202.54.162:78607/
    restart: unless-stopped
    stop_grace_period: 2m
```

# Backup vs. Long-Term Backup
## Definitions
**Backup**: A compressed archive containing a snapshot of the game files at a particular point in time. These are intended to be taken hourly or daily and retained for relatively short periods of time (2-3 days for hourly backups, 1-2 weeks for daily)

**Long-Term Backup**: A copy of the latest backup that is moved to a longer-term storage area, intended to be used for off-site and/or disaster recovery storage.

## Why bother with Long-Term backups?

Using Long-Term backups is a habit we have gotten into after many years of hosting our own game servers. Typically, we do daily backups and once per week will take a long-term backup of the latest backups that we store on a separate file server.

Here are a few use-cases that we have run into that will help inform why we encourage this practice:

- The game server has been idle for several weeks/months and the save file had gotten corrupted
- The server hosting the game (and its backups!) had a catastrophic failure and the data was lost
- Players wanted a copy of the game files from an earlier point in time
- A portion of the save files became corrupt at some point, but nobody went to that particular spot in several weeks to discover the issue (I'm looking at you, heavily modded Minecraft server!)

# Support
If you have any questions/concerns/suggestions, we're open to any and all constructive feedback. Feel free to open a PR or Issue.

You can also reach out to us via any of these methods:
- Website - https://diceninajagaming.com/pages/contact
- Discord - https://discord.gg/H3Q65fH5Cf
- Twitter - https://twitter.com/diceninjagaming
- Facebook - https://www.facebook.com/diceninjagaming/

# Contributing
This repo is maintained by Dice Ninja Gaming and [Taegost](https://github.com/Taegost)

We welcome anybody that would like to contribute, especially to help us add more supported games. Feel free to fork the repo and put in pull requests.

If you're not a coder, that's totally fine too! Reach out to us and we're more than happy to work with you to add features and games!

## Architecture
Powershell was chosen to be the primary scripting language for this project due to its portability, extensibility, and large support community. 

Any Bash scripts, commands, and utilities are to be kept to the absolute minimum required to make a good product. Unfortunately, the documentation for many of those tools (squints at cron) and their implementation (squints harder at cron) are very unfriendly to the user and don't lend themselves to easily readable code.