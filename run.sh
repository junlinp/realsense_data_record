docker image inspect realsense_record >/dev/null 2>&1 || docker build -t realsense_record .


docker rm -f realsense_record
docker run \
	-d \
	--name realsense_record \
	--env DISPLAY=$DISPLAY \
	--env QT_X11_NO_MITSHM=1 \
	--volume="/tmp/.X11-unix:/tmp/.X11-unix" \
	--net=host \
	--device /dev/dri \
	-v /dev/bus/usb:/dev/bus/usb \
	-v /etc/udev:/etc/udev \
	--device-cgroup-rule='c 81:* rmw' \
	--device-cgroup-rule='c 189:* rmw' \
	--privileged \
	-v .:/workspace \
	realsense_record /bin/bash -c 'ros2 launch realsense2_camera rs_launch.py   rgb_camera.profile:=640x480x30   depth_module.profile:=640x480x30 enable_infra1:=true enable_infra2:=true depth_module.emitter_enabled:=false depth_module.enable:=true'

docker exec -it realsense_record bash -c 'source /opt/ros/foxy/setup.sh && cd /workspace && ros2 bag record -a'

#ros2 launch realsense2_camera rs_launch.py   rgb_camera.profile:=640x480x30   depth_module.profile:=640x480x30 enable_infra1:=true enable_infra2:=true depth_module.emitter_enabled:=false depth_module.enable:=true

