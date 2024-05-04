#!/usr/local/env sh
# Builds a small alpine rootfs, and installs octoprint into it.

set -eu

# alpine packages required to install octoprint
readonly O4A_PKGS='alpine-keys apk-tools gcc python3 py3-pip libffi-dev python3-dev musl-dev curl git linux-headers openssh-server p7zip bash unzip ffmpeg'
readonly ALPINE_BRANCH='3.19'

sudo sh scripts/alpine-make-rootfs.sh \
    --arch $ARCH \
    --branch $ALPINE_BRANCH \
    --packages "$O4A_PKGS" \
    --script-chroot \
    build/rootfs.tar.xz ./scripts/setup-alpine-rootfs.sh