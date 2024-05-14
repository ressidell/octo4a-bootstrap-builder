#!/usr/local/env sh
# statically builds proot

BUILD_DIR="$(pwd)/build"

. ./scripts/config-ndk.sh

cd external/proot/src

# Build binaries for selected platform
config_ndk $ARCH

echo "Building static proot for $ARCH"

export CFLAGS="-I$STATIC_ROOT/include -DARG_MAX=131072"
export LDFLAGS="-L$STATIC_ROOT/lib"
export PROOT_UNBUNDLE_LOADER='../libexec/proot'

if [ $BUILD_PRE5 ]
then export ANDROID_PRE5=1
else unset ANDROID_PRE5
fi

# clean previous build
make distclean || true
make V=1 "PREFIX=$INSTALL_ROOT" install
mkdir -p $INSTALL_ROOT/bin/$PROOT_UNBUNDLE_LOADER

# copy proot loader and loader32
cp $PROOT_UNBUNDLE_LOADER/* $INSTALL_ROOT/bin/$PROOT_UNBUNDLE_LOADER/
(
    cd "$INSTALL_ROOT/bin"
    for FN in *; do
        "$STRIP" "$FN"
    done
)

(
    cd "$INSTALL_ROOT/bin/$PROOT_UNBUNDLE_LOADER"
    for FN in *; do
        "$STRIP" "$FN"
    done
)

cd $BUILD_DIR/..
