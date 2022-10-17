#!/bin/bash

container_name=$1
image_name=$2
echo $container_name
echo $image_name
#exit

XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi
xhost +local:docker

# # interactive, terminal
# -it \                
# # Add 'all' gpus to the container
# --gpus all \                
# # Set terminal colors
# -e "TERM=xterm-256color" \
# # Set display environment variable to copy host's value
# --env="DISPLAY=$DISPLAY" \
# # Set network interface to be the host so that the container can access all
# --net=host \
# # network interfaces exactly as the host
# --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
# # GUI Settings
# --env="QT_X11_NO_MITSHM=1" \
# # Mount X11 server directory to be able to use GUI inside the container
# --env="XAUTHORITY=$XAUTH" \
# # I don't know what is this !!!
# --volume="$XAUTH:$XAUTH" \
# # Use NVIDIA runtime in the container
# --runtime=nvidia \
# # Pass container name and image to use through terminal args
# --name "$container_name" "$image_name"

docker run \
    -it \
    --gpus all \
    -e "TERM=xterm-256color" \
    --env="DISPLAY=$DISPLAY" \
    --net=host \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env="QT_X11_NO_MITSHM=1" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --runtime=nvidia \
    --name "$container_name" "$image_name"

#export containerId=$(docker ps -l -q)

    
    
    
    
    
    
    
    
    