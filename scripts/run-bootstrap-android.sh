#!/system/bin/sh
PATH='/sbin:/usr/sbin:/bin:/usr/bin'
USER='root'
HOME='/root'
OP="-0"

BASE_DIR="$PWD"

export PROOT_TMP_DIR="$BASE_DIR/tmp"
export PROOT_L2S_DIR="$BASE_DIR/bootstrap/.proot.meta"

mkdir -p "$PROOT_TMP_DIR"
mkdir -p "$PROOT_L2S_DIR"

unset TMPDIR
unset LD_LIBRARY_PATH
export PATH
export USER
export HOME
shift

./bin/proot -r bootstrap/ -0 --kill-on-exit -0 -b /system:/system -b /vendor:/vendor -b /apex:/apex --link2symlink  -w $HOME /bin/sh
