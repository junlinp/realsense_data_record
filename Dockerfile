FROM ros:foxy

RUN apt-get update
RUN  apt-get install -y --fix-missing \
	curl 

RUN mkdir -p /etc/apt/keyrings
RUN curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | sudo tee /etc/apt/keyrings/librealsense.pgp > /dev/null
RUN echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | \
      tee /etc/apt/sources.list.d/librealsense.list
RUN apt-get update

RUN apt-get install -y librealsense2-dkms librealsense2-utils


RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list

#RUN add-apt-repository restricted && \
#    add-apt-repository universe && \
#    add-apt-repository multiverse

RUN apt-get install -y ros-foxy-realsense2-*

RUN bash /opt/ros/foxy/setup.bash

#COPY entrypoint.sh /
#RUN chmod +x /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]

CMD ["bash"]


