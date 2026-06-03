FROM ubuntu:jammy

ENV ROS_DISTRO=humble
ENV SIM_WS=/home/sim_ws
ARG DEBIAN_FRONTEND=noninteractive

# Add the ROS deb repo to the apt sources list
RUN apt update && \
        apt install -y --no-install-recommends \
		curl wget gnupg2 lsb-release ca-certificates console-setup \
        python3 python3-pip python3-setuptools locales \
        git unzip build-essential cython3 \
        htop zip dos2unix tmuxp xclip ranger python3-venv \
        python-is-python3 software-properties-common \
    && locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/* && apt-get clean
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS2
RUN apt update && \
    apt install -y --no-install-recommends \
		ros-${ROS_DISTRO}-desktop \
        ros-${ROS_DISTRO}-usb-cam \
        ros-${ROS_DISTRO}-image-transport-plugins \
        python3-colcon-common-extensions \
        ros-dev-tools \
        v4l-utils \
    && rm -rf /var/lib/apt/lists/* && apt-get clean

# Set up ROS2
RUN rosdep init && rosdep update --include-eol-distros

# Kill the bell!
RUN echo "set bell-style none" >> /etc/inputrc

# Create racecar_ws directory and src before switching to USER
RUN mkdir -p ${SIM_WS}/src && cd ${SIM_WS}/src && \
    git clone https://github.com/ros-drivers/usb_cam.git && \
    cd ${SIM_WS} && \
    /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && colcon build;'

# Copy in default config files
COPY config/params.yaml /camera/config/params.yaml
COPY ./entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod +x /usr/bin/entrypoint.sh && \
    usermod -aG video root

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash", "-c", "source /opt/ros/${ROS_DISTRO}/setup.bash && \
    ros2 run usb_cam usb_cam_node_exe --ros-args --params-file /camera/config/params.yaml"]