#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# Removes Container for services defined in the Compose file
docker-compose down

# If file exists will overwrite the .env file to have the docker container enviroment variable
# which file it should be considering on the read process 
if test -f "$1"; then
  filesize=$(find "$1" -printf "%s")
  nlines=$(wc -l $1 | awk '{ print $1 }')
  echo Setting ENV variables based on input...
  printf "FILE_NAME=$1\nFILE_SIZE=$filesize\nFILE_LINES=$nlines" > .env
  echo Server awakening...
  docker-compose --env-file .env up -d
  echo File pre-processing is complete!
  docker exec -it $(docker ps -aqf "name=salsify_web") rails db:create db:migrate
  echo "Pre-processing input file. Depending on the file size, this might take a while..."
  docker exec -it $(docker ps -aqf "name=salsify_web") rails pre_processing:file
  echo File pre-processing is complete!
  echo Server is running considering the file $1: 'http://localhost:3000/lines/1'
else
  echo ERROR: File must exist be present in root directary.
fi