if ! docker image inspect realsense_record >/dev/null 2>&1; then
  echo "Docker image 'realsense_record' not found. Building..."
  docker build -t realsense_record .
else
  echo "Docker image 'realsense_record' already exists."
fi


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
	realsense_record /bin/bash -c 'ros2 launch realsense2_camera rs_launch.py  depth_module.profile:=848x480x30 enable_infra1:=true enable_infra2:=true enable_sync:=true enable_accel:=true enable_gyro:=true accel_fps:=200 depth_module.emitter_enabled:=0 depth_module.enable:=true & sleep 5 && ros2 param set /camera/camera depth_module.emitter_enabled 0 && tail -f /dev/null'

docker exec -it realsense_record bash -c 'source /opt/ros/foxy/setup.sh && cd /workspace && ros2 bag record /camera/infra1/camera_info /camera/infra1/image_rect_raw /camera/infra1/metadata /camera/infra2/camera_info /camera/infra2/image_rect_raw /camera/infra2/metadata /camera/extrinsics/depth_to_infra1 /camera/extrinsics/depth_to_infra2 /camera/accel/sample /camera/gyro/sample'
