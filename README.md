# Dockerfile (Micropolis Robotics)

## Supported features/libraries:  
- Base image: [nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04](https://hub.docker.com/layers/nvidia/cuda/11.3.1-cudnn8-devel-ubuntu20.04/images/sha256-459c130c94363099b02706b9b25d9fe5822ea233203ce9fbf8dfd276a55e7e95)  
- CMake v3.24.2  
- CUDA v11.3.1  
- OpenCV v4.5.2 
- VTK v8.2.0 
- PCL v1.11  
- ROS2 foxy (and Gazebo)  
- NVIDIA-Accelerated  
- SSH-Enabled  
- External workspace mounted at (`/home/$USERNAME/Docker/$CONTAINER_NAME_workspace`)  

## Known issues:  

- `rviz2` is not working but this can be solved by running ROS2 accros multiple machines by setting up `ROS_DOMAIN_ID` & `ROS_DISCOVERY_SERVER` environment variables on your **host PC**

## Requirements
- Install docker from [official documentation](https://docs.docker.com/engine/install/ubuntu/)
- Proceed to the [Post-Installation steps](https://docs.docker.com/engine/install/linux-postinstall/) for Linux
- Install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)
- Configure local docker registry as follows
  1. Run
        ```bash
        $ sudo nano /etc/docker/daemon.json
        ```
  2. Edit the file `daemon.json` as below 
        ```json
        {
            "runtimes": {
                "nvidia": {
                    "path": "nvidia-container-runtime",
                    "runtimeArgs": []
                }
            },
            "insecure-registries" : ["X.X.X.X:5002"] <-- ADD THIS LINE 
                                                         (X.X.X.X = Server IP)
        }
        ```
        Then save and exit
  3. Restart Docker for the changes to take effects
        ```bash
        $ sudo systemctl daemon-reload
        $ sudo systemctl restart docker
        ```  
- Configure ROS2 across multiple machines  
    ```bash
    $ echo "export ROS_DISCOVERY_SERVER=X.X.X.X:11811" >> ~/.bashrc
    $ echo "export ROS_DOMAIN_ID=<your_domain_id>" >> ~/.bashrc
    ```  
    Where:
    - `X.X.X.X`  = Server IP
    - `<your_domain_id>` = 0-101 inclusive ([ROS2 Documentation](https://docs.ros.org/en/foxy/Concepts/About-Domain-ID.html#choosing-a-domain-id-long-version))
## How to use
The image is already built and pushed on our local server
- To get the image locally on your host PC run:  
  `docker pull X.X.X.X:5002/upolis:latest` (`X.X.X.X`  = Server IP)  
- To run a container based on `upolis` image, use the file `docker-launch.sh` in this repository as follows
    ```bash
    $ git clone https://github.com/eslaaam3/upolis_docker/
    $ chmod +x docker-launch.sh
    $ # ./docker-launch.sh <container_name> <image_name>
    $ ./docker-launch.sh <container_name> X.X.X.X:5002/upolis:latest
    ```
- Once you're inside the container, there's a directory on your **host PC** mounted to the container where you can share files between host PC and container
  ```bash
                      H O S T   P C               :  CONTAINER
  ~/Docker/<container_name>_workspace_<date_time> : ~/workspace
  ```
- Super user password inside the container is `upolis`, and it can be changed using `chpasswd` command, but generally, there is no need to change it