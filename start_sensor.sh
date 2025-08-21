set -e
source /opt/ros/humble/setup.bash
source /3rdparty/ros2_ws/install/local_setup.bash
ros2 launch realsense2_camera rs_launch.py  \
	depth_module.auto_exposure_limit:=1000 &\
	sleep 5 && \
       	ros2 param set /camera/camera depth_module.emitter_enabled 0 \
	&& tail -f /dev/null


