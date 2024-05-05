#!/system/bin/sh

if [ ! -d "bootstrap" ]; then
    echo "No bootstrap detected, extracting"
    # set permissions
    chmod -R 700 .
    chmod -R +rx .

    # make the bootstrap directory
    mkdir bootstrap
    cd bootstrap

    # extract and delete rootfs
    cat ../rootfs.tar.xz | ../bin/minitar
    rm -rf ../rootfs.tar.xz
    cd ..
fi

PATH='/sbin:/usr/sbin:/bin:/usr/bin'
USER='root'
HOME='/root'
OP="-0"

BASE_DIR="$PWD"

export PROOT_TMP_DIR="$BASE_DIR/tmp"
export PROOT_L2S_DIR="$BASE_DIR/bootstrap/.proot.meta"

mkdir -p "$PROOT_TMP_DIR"
mkdir -p "$PROOT_L2S_DIR"

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

./proot -r ../bootstrap -0 --kill-on-exit -b /dev -b /proc -b /system:/system -b /vendor:/vendor -b /apex:/apex --link2symlink -w $HOME
