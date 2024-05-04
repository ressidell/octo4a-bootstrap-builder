#!/usr/local/env sh
# statically builds the ioctl hook, used by octo4a to fake a serial device with pseudotty

BUILD_DIR="$(pwd)/build"

# Get NDK defines
. ./scripts/config-ndk.sh
config_ndk $ARCH

$CC -fPIC -c -o $BUILD_DIR/ioctlHook-$ARCH.o src/ioctlHook.c
$CC -shared -o $BUILD_DIR/ioctlHook-$ARCH.so $BUILD_DIR/ioctlHook-$ARCH.o -ldl

echo "IOCTL hook built properly"