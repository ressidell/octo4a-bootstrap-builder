#!/env/sh
# statically builds talloc 2.4.0

. ./scripts/config-ndk.sh

mkdir build-talloc

readonly BUILD_ROOT="$(pwd)/build-talloc"
cd external/talloc

config_ndk aarch64

echo "$CC"
./configure "--prefix=$BUILD_ROOT" --disable-rpath --disable-python --cross-compile --cross-answers=cross-answers-ndk21.txt