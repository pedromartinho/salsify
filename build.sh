# Stop and remove all docker images
docker stop $(sudo docker ps -a -q)
docker rm $(sudo docker ps -a -q) -f
docker rmi $(sudo docker images -q) -f

# Build application container
sudo docker-compose build