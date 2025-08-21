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
	realsense_record /bin/bash /start_sensor.sh

docker exec -it realsense_record bash /record.sh
