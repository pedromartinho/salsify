#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# Removes Container for services defined in the Compose file
docker-compose down

# If file exists will overwrite the .env file to have the docker container enviroment variable
# which file it should be considering on the read process 
if test -f "$1"; then
  echo "Setting ENV variables base on input..." 
  echo "FILE_NAME=$1" > .env
  echo "Compress file"
  gzip $1
  docker-compose --env-file .env up -d
  echo Server is running considering the file $1: 'http://localhost:3000/lines/1'
else
  echo "ERROR: File must exist be present in root directary."
fi