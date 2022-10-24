FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
# =============================================== #
#               ADD A NEW SUDO USER               #
# =============================================== #
ENV USERNAME upolis
ENV HOME /home/$USERNAME

# Add a user named $USERNAME and create its home directory (-m)
# # RUN useradd -m $USERNAME && \

# set the new user's password as username:password using chpasswd
# # echo "$USERNAME:$USERNAME" | chpasswd && \

# Modify the user $USERNAME to select a login shell for this user as /bin/bash
# # usermod --shell /bin/bash $USERNAME && \

# Modify the user $USERNAME to append (-a) it to the group (-G) sudo
# # usermod -aG sudo $USERNAME && \

# Make a new directory /etc/sudoers.d
# # mkdir /etc/sudoers.d && \

# Adding user account to sudoers
# # echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \

# Set permissions for the new user
# # chmod 0440 /etc/sudoers.d/$USERNAME && \

# Set the user/group id for the new user
# # Replace 1000 with your user/group id
# # usermod  --uid 1000 $USERNAME && \
# # groupmod --gid 1000 $USERNAME

RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        mkdir /etc/sudoers.d && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        # Replace 1000 with your user/group id
        usermod  --uid 1000 $USERNAME && \
        groupmod --gid 1000 $USERNAME


# =============================================== #
#           INSTALL ESSENTIAL PACKAGES            #
# =============================================== #

RUN echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" > /etc/apt/apt.conf.d/docker-gzip-indexes
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && TZ=Etc/UTC apt-get install -y --no-install-recommends \
        build-essential \
        sudo \
        less \
        apt-utils \
        tzdata \
        git \
        tmux \
        bash-completion \
        command-not-found \
        software-properties-common \
        curl \
        wget\
        gnupg2 \
        lsb-release \
        keyboard-configuration \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# =============================================== #
#              INSTALL libGL & FRIENDS            #
# =============================================== #

RUN apt-get update \
    && apt-get install -y \
        libssl-dev \
        libgl1-mesa-dev

# ============================================= #
#                INSTALL CMake                  #
# ============================================= #
WORKDIR /tmp
ENV CMAKE_VERSION="3.24.2"
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz \
    && tar -xvf cmake-${CMAKE_VERSION}.tar.gz \
    && cd cmake-${CMAKE_VERSION} \
    && ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release \
    && make \
    && make install

# ============================================= #
#                 INSTALL VTK                   #
# ============================================= #
WORKDIR /tmp

RUN apt-get update && apt-get install -y \
    libxt-dev 

RUN wget https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz \
    && tar -xf VTK-8.2.0.tar.gz \
    && cd VTK-8.2.0 && mkdir build && cd build \
    && cmake .. -DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2=YES \
                -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) \
    && make install


# =============================================== #
#                Installing PCL library           #
# =============================================== #
WORKDIR /tmp
ENV PCL_VERSION="1.11.0"

    # ======= PCL dependencies =======
RUN apt-get install -y \
    libeigen3-dev \
    libflann-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    mesa-common-dev \
    libboost-all-dev \
    libusb-1.0-0-dev \
    libusb-dev \
    libopenni-dev \
    libopenni2-dev \
    libpcap-dev \
    libpng-dev \
    mpi-default-dev \
    openmpi-bin \
    openmpi-common \
    libqhull-dev \
    libgtest-dev

    # ======= PCL source download & build =======
RUN wget https://github.com/PointCloudLibrary/pcl/archive/pcl-${PCL_VERSION}.tar.gz \
    && tar -xf pcl-${PCL_VERSION}.tar.gz \
    && cd pcl-pcl-${PCL_VERSION} \
    && mkdir build && cd build\
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
                -DVTK_RENDERING_BACKEND=OpenGL2 \
    && make -j$(nproc)\
    && make install

RUN apt-get update && apt-get install -y pcl-tools

RUN unset PCL_VERSION


# ============================================================ #
#            Installing OpenCV library (with CUDA)             #
# ============================================================ #

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3-pip \
    unzip \
    libatlas-base-dev \
    libgtk2.0-dev \
    pkg-config \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    x11-apps \
    zlib1g-dev ffmpeg libwebp-dev \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev \
    libopenmpi-dev openmpi-bin openmpi-common openmpi-doc \
    libhdf5-dev

WORKDIR /tmp
ENV OPENCV_VERSION="4.5.2"
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz \
    && wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/refs/tags/${OPENCV_VERSION}.zip \
    && tar -xf ${OPENCV_VERSION}.tar.gz \
    && unzip opencv_contrib.zip \
    && pip3 install numpy mpi4py\
    && cd opencv-${OPENCV_VERSION} \
    && mkdir build && cd build \
    && cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local -D BUILD_opencv_python3=ON -D WITH_CUDA=ON -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -D WITH_GTK=ON -D WITH_VTK=ON -D CUDA_ARCH_BIN=6.0 6.1 7.0 7.5 8.6 -D INSTALL_C_EXAMPLES=ON -D WITH_TBB=ON -D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 -D WITH_CUDNN=ON -D OPENCV_DNN_CUDA=ON -D PYTHON_EXECUTABLE=/usr/bin/python3 -D OPENCV_PYTHON3_INSTALL_PATH=/usr/local/lib/python3.8/dist-packages -D BUILD_EXAMPLES=OFF -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules .. \
    && make -j$(nproc) \
    && make install

# ==================================================== #
#                   INSTALL ROS2 FOXY                  #
# ==================================================== #
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt-get update && apt-get install -y \
        ros-foxy-ros-base \
        ros-foxy-gazebo-* \
        ros-foxy-rmw-cyclonedds-cpp \
        python3-argcomplete \
        python3-colcon-common-extensions \
        python3-pip \
        python3-vcstool \
        python3-rosdep \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN rosdep init


# ========================================= #
#               POST-BUILD                  #
# ========================================= #

    # ======== Install sublime text ==========
RUN wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
RUN sudo apt-get install apt-transport-https
RUN echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive sudo apt-get install sublime-text

    # ======= Installing basic pkgs/tools
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y \
    terminator \
    dbus \
    dbus-x11 \
    gdb \
    rsync \
    nano \
    psmisc \
    inetutils-inetd

    # =========== Cleaning up the messsssss ===========
WORKDIR /home/$USERNAME
RUN rm -rf /tmp/ && mkdir /tmp && chmod 1777 /tmp

    # ======== Config ssh ============
RUN apt-get install -y openssh-server
RUN ssh-keygen -A

    # ============ Configure apt-get autocompletion ============ #
RUN rm /etc/apt/apt.conf.d/docker-clean \
    && touch /etc/apt/apt.conf.d/docker-clean \
    && echo "DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };" > /etc/apt/apt.conf.d/docker-clean




# ====================================== #
#          ADD A NEW LAYER HERE          #
# ====================================== #



# ==================================================== #
#            LOGIN USING THE USER $USERNAME            #
# ==================================================== #

USER $USERNAME 
WORKDIR /home/$USERNAME
RUN rosdep update

# ========== Define build-args with default values ==========
ARG ROS_DISCOVERY_SERVER=10.20.0.249
ARG ROS_DOMAIN_ID=100

# ========== Add environment variables to .bashrc ==========
COPY bashrc_update .
RUN cat bashrc_update >> ~/.bashrc \
    && sudo apt-get update

EXPOSE 22

COPY entrypoint.sh .
RUN sudo chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]