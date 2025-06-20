#!/bin/bash

# This script runs a Docker container instance with a name based on [docker-project].
#
# Usage: bash RUN-DOCKER-CONTAINER.bash [docker-project] [ros-launch]
#
# [docker-project]: Used to name the Docker container and create multiple instances if needed.
#                   Default value is '$USER'.
# [ros-launch]:     Used to automatically preload a ROS launch file when entering the Docker container for convenience.
#                   Format is 'filename.launch'.

# ################################################################################

# # Load the default environment variables from the '.env' file:
# source ~/UR5e/.env

# # Overwrite the default environment variables with the user's variables from the '.env.custom' file (if it exists):
# if [ -f ~/UR5e/.env.custom ]; then
#   source ~/UR5e/.env.custom
# fi

# ################################################################################

# # Set the Docker container name from the [docker-project] argument.
# # If no [docker-project] is given, use the current user name as the Docker project name.
# DOCKER_PROJECT=$1
# if [ -z "${DOCKER_PROJECT}" ]; then
#   DOCKER_PROJECT=${USER}
# fi
# DOCKER_CONTAINER="${DOCKER_PROJECT}-ur5e-1"
# echo "$0: DOCKER_PROJECT=${DOCKER_PROJECT}"
# echo "$0: DOCKER_CONTAINER=${DOCKER_CONTAINER}"

# ################################################################################

# # Export current user and group IDs to 'docker-compose.yaml'.
# USER_ID="$(id -u)"
# GROUP_ID="$(id -g)"
# export USER_ID
# export GROUP_ID

################################################################################

# Display GUIs through X Server by granting access to Docker.
xhost +local:docker

################################################################################

# Run the Docker container in the background.
# Any changes made to './docker/docker-compose*.yml' will recreate and overwrite the container.
if [ -e /proc/driver/nvidia/version ]; then
  docker compose -p onishi-kazuma -f ./docker/docker-compose.yaml -f ./docker/docker-compose-gpu.yaml up -d
else
  docker compose -p onishi-kazuma -f ./docker/docker-compose.yaml up -d
fi

################################################################################

# Configure the known host names with '/etc/hosts' in the Docker container.

# ROS_MASTER_HOSTNAME=${ENV_ROS_MASTER_HOSTNAME}
# echo "Now resolving local host name '${ROS_MASTER_HOSTNAME}'..."
# ROS_MASTER_IP=`avahi-resolve -4 --name ${ROS_MASTER_HOSTNAME} | cut -f 2`
# if [ "$?" != "0" ]; then
#   echo "Failed to execute 'avahi-resolve'. You may need to install 'avahi-utils'."
#   docker exec -i ${DOCKER_CONTAINER} bash <<EOF
# sed -i 's/TMP_ROS_MASTER_HOSTNAME/${ROS_MASTER_HOSTNAME}/' ~/.bashrc
# EOF
# elif [ ! -z "${ROS_MASTER_IP}" ]; then
#   echo "Successfully resolved host name '${ROS_MASTER_HOSTNAME}' as '${ROS_MASTER_IP}': '/etc/hosts' in the container is automatically updated."
#   docker exec -i ${DOCKER_CONTAINER} bash <<EOF
# sed -i 's/TMP_ROS_MASTER_HOSTNAME/${ROS_MASTER_HOSTNAME}/' ~/.bashrc
# sed -n -e '/^[^#[:space:]]*[[:space:]]\+${ROS_MASTER_HOSTNAME}\$/!p' /etc/hosts > /etc/hosts.tmp;
# echo '${ROS_MASTER_IP} ${ROS_MASTER_HOSTNAME}' >> /etc/hosts.tmp
# cp /etc/hosts.tmp /etc/hosts;
# EOF
# else
#   echo "Failed to resolve host name '${ROS_MASTER_HOSTNAME}': '/etc/hosts' in the container was not automatically updated."
# fi

################################################################################

# # Enter the Docker container with a Bash shell (with or without preloading a custom [ros-launch] file).
if [ -z "$2" ]; then
  docker exec -i -t onishi-kazuma-genesis-1 bash
fi
# else
#   docker exec -i -t ${DOCKER_CONTAINER} bash -i -c "source ~/UR5e/docker/ur5e-devel/scripts/run-roslaunch-repeatedly.bash $2"
# fi
