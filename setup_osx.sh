#!/usr/bin/env bash

# Sets up docker on OSX and configures a VM + NFS shares

set -x
set -e

function command_exists() {
	return command -v $1 >/dev/null 2>&1
}

DOCKER_VM="docker-vm"
DOCKER_IMAGE="pjameson/buck-folly-watchman"

if ! command -v docker >/dev/null 2>&1; then
	echo "docker is not installed, installing with brew..."
	brew install docker
fi

if ! command -v docker-machine >/dev/null 2>&1; then
	echo "docker-machine is not installed, installing with brew..."
	brew install docker-machine
fi

if ! command -v VBoxManage >/dev/null 2>&1; then
	echo "VBoxManage is not installed, installing virtualbox with brew..."
	brew install caskroom/cask/brew-cask
	brew cask install virtualbox
fi

if ! docker-machine status "${DOCKER_VM}" >/dev/null 2>&1; then
	echo "${DOCKER_VM} does not exist, creating..."
	docker-machine create -d virtualbox "${DOCKER_VM}"
fi

docker-machine start "${DOCKER_VM}"

LOCAL_HOSTONLY_IP="$(ifconfig | grep 'inet 192.168.99' | head -n 1 | awk '{print $2}')"
DOCKER_VM_IP="$(docker-machine ip "${DOCKER_VM}")"
USER_NAME="$(id -un)"
GROUP_NAME="$(id -gn)"

# Setup our local nfs share
if [ ! -f /etc/exports ] || ! grep "/Users.*${DOCKER_VM_IP}" /etc/exports >/dev/null 2>&1; then
	echo "Adding /Users to /etc/export for faster, more functional IO in docker"
	echo "/Users -mapall=${USER_NAME}:\"${GROUP_NAME}\" ${DOCKER_VM_IP}" | sudo tee /etc/exports >/dev/null
	sudo nfsd restart
fi

# Startup NFS and mount our local nfs share (after unmounting the vboxsf share)
docker-machine ssh "${DOCKER_VM}" "sudo /usr/local/etc/init.d/nfs-client start"
docker-machine ssh "${DOCKER_VM}" "if ! grep '/Users.* nfs' /proc/mounts; then sudo umount /Users; sudo mount ${LOCAL_HOSTONLY_IP}:/Users /Users -o rw,async,noatime,rsize=32768,wsize=32768,proto=tcp,vers=3 -t nfs; fi"

set +x

echo "

Docker VM should be up and running now!

To run docker commands setup the environment with:
  eval \"\$(docker-machine env ${DOCKER_VM})\"

To build a local buck project with c++14, run
  eval \"\$(docker-machine env ${DOCKER_VM})\"
  docker run -v /my/project/local/path:/my/project/local/path --rm -it ${DOCKER_IMAGE} /bin/bash 
  cd /my/project/local/path && buck build

To see a \"hello, world\" application that uses folly and has tests, run:
  eval \"\$(docker-machine env ${DOCKER_VM})\"
  docker run --rm -it ${DOCKER_IMAGE} /bin/bash 
  cd /root/src/helloworld
  buck run src:HelloWorld
  buck test src:

"
