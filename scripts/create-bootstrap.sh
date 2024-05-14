#!/usr/bin/env sh
# Generates a full octo4a bootstrap + startup scripts for a given architecture

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: <arch> <octoprint version> <bootstrap shortsha>"
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
export BOOTSTRAP_SHA=$3
export BUILD_DIR="$PWD/build"

rm -rf build/
mkdir build/

# Download octoprint release
echo "Downloading OctoPrint release $OCTOPRINT_VERSION"
curl -o build/octoprint.tar.gz -L https://github.com/OctoPrint/OctoPrint/releases/download/$OCTOPRINT_VERSION/OctoPrint-$OCTOPRINT_VERSION.tar.gz

# Unpack octoprint, move to a dir easily accessible from the chroot
tar -xzf build/octoprint.tar.gz -C build/

OCTOPRINT_LOWERCASE_DIR="build/octoprint-$OCTOPRINT_VERSION"
OCTOPRINT_UPPERCASE_DIR="build/OctoPrint-$OCTOPRINT_VERSION"

if [ -d "$OCTOPRINT_LOWERCASE_DIR" ]; then
    echo "Lowercase octoprint dir detected, moving"
    mv $OCTOPRINT_LOWERCASE_DIR build/octoprint
fi

if [ -d "$OCTOPRINT_UPPERCASE_DIR" ]; then
    echo "Uppercase octoprint dir detected, moving"
    mv $OCTOPRINT_UPPERCASE_DIR build/octoprint
fi

BUILD_PRE5=false

# Build talloc, proot
. ./scripts/build-talloc.sh
. ./scripts/build-proot.sh

if [ "$ARCH" == 'armv7a' ] || [ "$ARCH" == 'i686' ]; then
    # for API level <21, we need to get separate proot and talloc binaries
    BUILD_PRE5=true
    . ./scripts/build-talloc.sh
    . ./scripts/build-proot.sh
fi

echo "Building minitar binaries"
cd external/minitar
sh build.sh
cd ../../

echo "Building ioctl hook"
. ./scripts/build-ioctl-hook.sh

# Copy into non-arch specfic file, for access from chroot bind
cp build/ioctlHook-$ARCH.so build/ioctl-hook.so

# Build alpine bootstrap
. ./scripts/build-octo4a-bootstrap.sh

echo "Preparing full bootstrap archive"
mkdir build/bootstrap-dir

# include proot
cp -r build/root-$ARCH/root/* build/bootstrap-dir/

# include bootstrap archive
mv build/rootfs.tar.xz build/bootstrap-dir/

# include minitar
cp external/minitar/build/libs/$ARCH_NDK/minitar build/bootstrap-dir/bin

# include entrypoint script
cp scripts/run-bootstrap-android.sh build/bootstrap-dir/entrypoint.sh

# misc
cp src/fake_proc_stat build/bootstrap-dir/

# short ver to the bootstrpa
echo "$OCTOPRINT_VERSION-$BOOTSTRAP_SHA" >>build/bootstrap-dir/build-version.txt

# Compress the complete bootstrap
cd build/bootstrap-dir && zip -r ../bootstrap-$OCTOPRINT_VERSION-$ARCH.zip *

echo "Bootstrap successfully built - compressed as build/bootstrap-$OCTOPRINT_VERSION-$ARCH.zip"
