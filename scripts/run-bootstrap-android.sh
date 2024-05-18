#!/system/bin/sh
# Minimal proot run script, used as entrypoint in bootstrap

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Usage: <user> <command>"
	exit 1
fi

BASE_DIR="$PWD"

export PROOT_TMP_DIR="$BASE_DIR/tmp"
export PROOT_L2S_DIR="$BASE_DIR/bootstrap/.proot.meta"

if [ ! -d "bootstrap" ]; then
    echo "No bootstrap detected, extracting"

    # make the bootstrap directories
    mkdir bootstrap
    mkdir -p "$PROOT_TMP_DIR"
    mkdir -p "$PROOT_L2S_DIR"

    # set permissions
    chmod -R 700 ../
    chmod -R +rx ../

    cd bootstrap

    # extract and delete rootfs
    cat ../rootfs.tar.xz | ../bin/minitar
    rm -rf ../rootfs.tar.xz

    cd ..
fi

if [ "$1" = "root" ]; then
	PATH='/sbin:/usr/sbin:/bin:/usr/bin'
	USER='root'
	HOME='/root'
	OP="-0"
else
	OP=""
	USER="$1"
	PATH='/sbin:/usr/sbin:/bin:/usr/bin'
	HOME="/home/$USER"
fi

# unset envs
unset TMPDIR
unset LD_LIBRARY_PATH
unset LD_PRELOAD

# export proper paths
export PATH
export USER
export HOME

# proot refers to ../libexec, hence PWD is necessary
cd bin/

shift

./proot -r ../bootstrap/ $OP -b /dev -b /proc -b /storage -b /system -b /vendor -b /apex -b ${PWD}/../fake_proc_stat:/proc/stat $EXTRA_BIND -L --link2symlink -w $HOME "$@"
