# docker_cardinal
Repository to build and test Cardinal using Docker

# build instruction
# docker build -t user_name/image_name:tag_name . (. is technically path to directory containing Dockerfile)
# if no tag is used, the tag latest will be applied to the image with the most recent build
docker build -t ligross/cardinal:cardinal_stable .
# if you want a build from no cache
docker build --no-cache -t ligross/cardinal:cardinal_stable .


# run in interactive mode with -i 
# docker container run -it [image id] or 
# you can use docker run -it <user>/repo:tag
docker run -it ligross/cardinal:cardinal_stable

# push instructions
docker push ligross/cardinal:cardinal_stable