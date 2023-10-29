# This script is simply to facilitate development.

docker build -t diceninjagaming/gportal-backup .

docker compose -f ./docker-compose.yml down
docker compose -f ./docker-compose.yml up -d