#!/bin/bash -x

ARCH=$1
amdSDK="https://download.stereolabs.com/zedsdk/3.7/cu113/ubuntu20"
armSDK="https://download.stereolabs.com/zedsdk/3.7/l4t35.1/jetsons"
SDKLINK=$amdSDK
if [[ $ARCH == arm64 ]] ; then 
    export SDKLINK=$armSDK
fi

wget -q --no-check-certificate -O ZED_SDK_Linux.run $SDKLINK
chmod +x ZED_SDK_Linux.run && ./ZED_SDK_Linux.run silent && rm -rf ZED_SDK_Linux.run

if [[ $ARCH == arm64 ]] ; then 
    ln -sf /usr/lib/aarch64-linux-gnu/tegra/libv4l2.so.0 /usr/lib/aarch64-linux-gnu/libv4l2.so
fi