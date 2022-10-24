#!/bin/bash
container_name=$1
image_name=$2
if [[ ! -d ~/${container_name}_workspace ]]; then
    echo "doesn't exists"
    mkdir ~/${container_name}_workspace
fi