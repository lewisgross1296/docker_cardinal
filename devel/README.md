# docker_cardinal
Repository to build and test Cardinal using Docker. This directory specifically can be used to build the latest version of Cardinal. When planning to update to the newest version, the `--no-cache` option can be used so that the `git clone` grabs the newest version of Cardinal available

## build instructions
```
docker build -t user_name/image_name:tag_name .
```
If the Dockerfile is not located at `.`, you can supply the path. If no tag is used, the tag latest will be applied to the image with the most recent build.
## For building a known stable version of Cardinal, use
```
docker build -t ligross/cardinal:cardinal_devel .
```
## if you want a build from no cache (sometimes useful for debugging)
```
docker build --no-cache -t ligross/cardinal:cardinal_devel .
```
## run the image in interactive mode with -i
```
docker container run -it image_id
```
## you can also use docker run -it <user>/repo:tag
```
docker run -it ligross/cardinal:cardinal_devel
```
## push instructions
```
docker push ligross/cardinal:cardinal_devel
```

## for debugging an issue with the build, use these versions of the commands
```
docker build -t ligross/cardinal:cardinal_debug .
```
```
docker build --no-cache -t ligross/cardinal:cardinal_debug .
```
```
docker run -it ligross/cardinal:cardinal_debug
```
```
docker push ligross/cardinal:cardinal_debug
```