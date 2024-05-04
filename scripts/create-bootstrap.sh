#!/env/sh
# Generates a full octo4a bootstrap + startup scripts for a given architecture
set -eu

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Usage: <arch> <octoprint version>"
	exit 1
fi

# Configures NDK for android cross-compilation
if [[ -z "${NDK_PATH}" ]]; then
    echo "NDK Path not set" >&2
    exit 1
fi

# add NDK to PATH
export PATH="$PATH:$NDK_PATH"
export ARCH=$1
export OCTOPRINT_VERSION=$2

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