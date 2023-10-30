FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get upgrade -y

# Download and register the Microsoft repository GPG keys
RUN apt-get install -y wget apt-transport-https software-properties-common
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
RUN dpkg -i packages-microsoft-prod.deb

# Update and install misc packages
RUN apt-get update
RUN apt-get install --no-install-recommends --no-install-suggests -y \
     ca-certificates cron curl lib32gcc-s1 locales p7zip-full powershell zip 

# Ensure cron is enabled.
# RUN cron start
RUN touch /var/log/cron.log
    
# Set up folders
WORKDIR /app
RUN mkdir -p ./backups
RUN mkdir -p ./working
RUN mkdir -p ./logs

# Copy scripts
WORKDIR /scripts
COPY --chmod=+x ./scripts/ .

WORKDIR /tmp

# Set up server defaults
ENV TZ="Etc/UTC" \
    FILE_UMASK="022" \
    BACKUPS_MAX_AGE_DAYS=3 \
    BACKUPS_MAX_COUNT=0 \
    CRON_EXPRESSION="0 0 * * *"

# HEALTHCHECK CMD sv status ddns | grep run || exit 1

# CMD pwsh /scripts/Entrypoint.ps1
ENTRYPOINT [ "/scripts/entrypoint.sh" ]
