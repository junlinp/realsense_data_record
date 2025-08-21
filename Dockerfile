FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# ros2
RUN apt-get update && apt-get install -y software-properties-common curl git\
    && rm -rf /var/lib/apt/lists/*
RUN add-apt-repository universe
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt-get update && apt-get install -y ros-humble-desktop \
    python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/*
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

WORKDIR /3rdparty

# realsense-sdk
RUN apt-get update && apt-get install -y --no-install-recommends \
    libudev-dev pkg-config libusb-1.0-0-dev libglfw3-dev libssl-dev libgl1-mesa-dev libglu1-mesa cmake \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/IntelRealSense/librealsense.git -b r/256 \
    && cd librealsense \
    && cp config/99-realsense-libusb.rules /etc/udev/rules.d/. \
    && mkdir build \
    && cd build \
    && cmake ../ -DFORCE_LIBUVC=true -DCMAKE_BUILD_TYPE=release -DBUILD_EXAMPLES=true \
    && make -j$(nproc) \
    && make install

# realsense-ros2 wrap
ENV ROS_DISTRO=humble
RUN mkdir -p ros2_ws/src \
    && cd ros2_ws/src \
    && git clone https://github.com/UniflexAI/realsense-ros.git -b ros2-master \
    && cd /3rdparty/ros2_ws \
    && apt-get update && apt-get install -y python3-rosdep \
    && rosdep init \
    && rosdep update \
    && rosdep install -i --from-path src --rosdistro $ROS_DISTRO --skip-keys=librealsense2 -y && rm -rf /var/lib/apt/lists/* \
    && . /opt/ros/humble/setup.sh \
    && colcon build
RUN echo "source /3rdparty/ros2_ws/install/local_setup.bash" >> ~/.bashrc

CMD ["bash"]


