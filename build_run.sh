docker stop lpr_container
docker rm lpr_container

docker build -t lpr_img .
docker run -p 8082:8082 --restart always --name lpr_container lpr_img
