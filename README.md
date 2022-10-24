# Supported features/libraries:  
- Base image: [nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04](https://hub.docker.com/layers/nvidia/cuda/11.3.1-cudnn8-devel-ubuntu20.04/images/sha256-459c130c94363099b02706b9b25d9fe5822ea233203ce9fbf8dfd276a55e7e95)  
- CMake v3.24.2  
- CUDA v11.3.1  
- OpenCV v4.5.2  
- PCL v1.11  
- ROS2 foxy (+Gazebo)  
- NVIDIA Accelerated  
- SSH-Enabled  
- External workspace mounted at (`/home/$USERNAME/$CONTAINER_NAME_workspace`)  

# Known issues:  

- `rviz2` is not working but this can be solved by running ROS2 accros multiple machines by setting up `ROS_DOMAIN_ID` & `ROS_DISCOVERY_SERVER` environment variables on your **host PC**
