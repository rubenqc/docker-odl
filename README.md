# docker-odl
The Docker image for OpenDaylight SDN Controller on Ubuntu 20.04. 

OpenDaylight SDN Controller - Phosphorus 15.1.0

## Github
[rubenqc/docker-odl](https://github.com/rubenqc/docker-odl)

## Docker Pull Command
Download from [Docker Hub](https://hub.docker.com/)
```shell script
docker pull rubenqc/odl
```

## Docker Run Command
```shell script
docker run -it --name odl_controller -p 8181:8181 -p 6640:6640 rubenqc/odl
```
