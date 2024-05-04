#!/env/sh

# Configures NDK for android cross-compilation
if [[ -z "${NDK_PATH}" ]]; then
    echo "NDK Path not set" >&2
    exit 1
fi

config_ndk() {
    if [ "$(uname)" == "Darwin" ]; then
        export TOOLCHAIN=$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64
    else
        export TOOLCHAIN=$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64
    fi

    case "$1" in
    "aarch64") export TARGET=aarch64-linux-android ;;
    "armv7a") export TARGET=armv7a-linux-androideabi ;;
    "i686") export TARGET=i686-linux-android ;;
    "x86_64") export TARGET=x86_64-linux-android ;;
    esac
    echo $TARGET

    # Set this to your minSdkVersion.
    export API=21
    # Configure and build.
    export AR="$TOOLCHAIN/bin/llvm-ar"
    export CC="$TOOLCHAIN/bin/$TARGET$API-clang"
    export AS="$CC"
    export CXX="$TOOLCHAIN/bin/$TARGET$API-clang++"
    export LD="$TOOLCHAIN/bin/ld"
    export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
    export STRIP="$TOOLCHAIN/bin/llvm-strip"
}
