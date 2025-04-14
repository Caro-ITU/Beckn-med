sudo docker stop $(sudo docker ps -aq)
sudo docker rm $(sudo docker ps -aq)
docker system prune -a --volumes
echo "y"