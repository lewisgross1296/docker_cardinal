# docker_cardinal
Repository to build and test Cardinal using Docker

## build instructions
```
docker build -t user_name/image_name:tag_name . 
```
If the Dockerfile is not located at `.`, you can supply the path. If no tag is used, the tag latest will be applied to the image with the most recent build.
## For building a known stable version of Cardinal, use
```
docker build -t ligross/cardinal:cardinal_stable .
```
## if you want a build from no cache (sometimes useful for debugging)
```
docker build --no-cache -t ligross/cardinal:cardinal_stable .
```
## run the image in interactive mode with -i
```
docker container run -it image_id
```
## you can also use docker run -it <user>/repo:tag
```
docker run -it ligross/cardinal:cardinal_stable
```
## push instructions
```
docker push ligross/cardinal:cardinal_stable
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