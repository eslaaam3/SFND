FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# Add a new sudo user
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

# -??
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



CMD [ "bash" ]