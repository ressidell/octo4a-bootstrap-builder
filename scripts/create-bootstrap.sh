#!/usr/bin/env sh
# Generates a full octo4a bootstrap + startup scripts for a given architecture

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Usage: <arch> <octoprint version>"
	exit 1
fi

set -e

# Configures NDK for android cross-compilation
if [[ -z "${NDK_PATH}" ]]; then
    echo "NDK Path not set" >&2
    exit 1
fi

# add NDK to PATH
export PATH="$PATH:$NDK_PATH"
export ARCH=$1
export OCTOPRINT_VERSION=$2
export BUILD_DIR="$PWD/build"

rm -rf build/
mkdir build/

# Download octoprint release
echo "Downloading OctoPrint release $OCTOPRINT_VERSION"
curl -o build/octoprint.tar.gz -L https://github.com/OctoPrint/OctoPrint/releases/download/$OCTOPRINT_VERSION/OctoPrint-$OCTOPRINT_VERSION.tar.gz

# Build talloc, proot
. ./scripts/build-talloc.sh
. ./scripts/build-proot.sh

echo "Building minitar binaries"
cd external/minitar
sh build.sh
cd ../../

# Build alpine bootstrap
. ./scripts/build-octo4a-bootstrap.sh

echo "Building ioctl hook"
. ./scripts/build-ioctl-hook.sh

echo "Preparing full bootstrap archive"
mkdir build/bootstrap-dir

# include proot
cp -r build/root-$ARCH/root build/bootstrap-dir/root

# include bootstrap archive
mv build/rootfs.tar.xz build/bootstrap-dir/

# include minitar
cp external/minitar/build/libs/$ARCH_NDK/minitar build/bootstrap-dir/root/bin

# include ioctl hook
cp build/ioctlHook-$ARCH.so build/bootstrap-dir/ioctl-hook.so

# include entrypoint script
cp scripts/run-bootstrap-android.sh build/bootstrap-dir/entrypoint.sh

# misc
cp src/fake_proc_stat build/bootstrap-dir/

# Compress the complete bootstrap
zip -r build/bootstrap-$OCTOPRINT_VERSION-$ARCH.zip build/bootstrap-dir/*

echo "Bootstrap successfully built - compressed as build/bootstrap-$OCTOPRINT_VERSION-$ARCH.zip"