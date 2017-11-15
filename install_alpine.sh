#!/bin/sh

distro=Alpine Linux
distro_short=alpine

alpine_version=3.6
alpine_sub=.2

rootfs_filename=alpine-minirootfs-${alpine_version}${alpine_sub}-x86.tar.gz
rootfs_url=http://dl-cdn.alpinelinux.org/alpine/v${alpine_version}/releases/x86/alpine-minirootfs-${alpine_version}${alpine_sub}-x86.tar.gz

edison_release=3.10.17-poky-edison+
os_release=$(uname -r)
force=no

while [ $# -gt 0 ]; do
    case "$1" in
        --force) force=yes
            ;;
    esac
    shift
done

if [ ! -d /factory ]; then
	echo == /factory is missing!
	echo ==
	echo == You don\'t appear to be running this script from an Edison module.
	echo == This script is only meant to be used with Edison modules running
	echo == the stock Yocto firmware.
	echo == If you *are* running this on an Edison module, something has gone
	echo == wrong and your partitions are not mounted correctly.
	echo == Try reflashing the stock Yocto build to your module using dfu_util.
	exit 1
fi

if [ $edison_release != $os_release ]; then
	if [ force != yes ]; then
		echo == Expected release $edison_release, got $os_release
		echo ==
		echo == You do not appear to be running the stock Edison yocto build.
		echo == This script is only tested on stock and may not work on anything
		echo == else. Pass --force to this script if you want to try anyway, but
		echo == do this at your own risk. If something goes wrong, your Edison
		echo == module may no longer boot. 
		echo ==
		echo == Custom kernels can also cause this error. If you are simply running
		echo == a custom kernel on the stock Yocto build, you may install safely
		echo == using --force.
		exit 2
	fi
fi

cd /tmp

if [ ! -f ${rootfs_filename} ]; then
	echo == Downloading rootfs...
	wget ${rootfs_url}
	if [ ! $? ]; then
		echo == Couldn\'t download the mini rootfs.
		echo == Check your internet connection.
		exit 3
	fi
fi

echo Mounting tmpfs on /mnt

mount -t tmpfs tmpfs /mnt
if [ ! $? ]; then
	echo == Failed to mount tmpfs on /mnt
	exit 4
fi

echo Extracting root filesystem

tar -xf alpine-minirootfs-${alpine_version}-x86.tar.gz -C /mnt
if [ ! $? ]; then
	echo == Failed to extract the archive.
	exit 5
fi

echo =====================================
echo Download and preparation is complete.
echo Ready to install $distro.
echo "  "
echo No changes have been made to your 

