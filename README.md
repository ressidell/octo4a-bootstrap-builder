# octo4a-bootstrap-builder

This repository contains a set of different scripts and GitHub Action workflow files, that are used to build a custom Alpine Linux rootfs, used by the [octo4a](https://github.com/feelfreelinux/octo4a) app.

It also builds proot, and includes it alongside the bootstrap archive. Proot is used to chroot into the rootfs on the Android device.

## Scripts
- `scripts/alpine-make-rootfs.sh` - modified version of [alpine-make-rootfs](https://github.com/alpinelinux/alpine-make-rootfs), used to build a custom version of the alpine-linux bootstrap, with Octoprint and necessary dependencies contained inside. The original script was altered to support multiple architectures.

- `scripts/build-talloc.sh` - Statically builds the talloc allocator, using Android NDK. Talloc is a dependency of proot.
- `scripts/build-proot.sh` - Statically builds proot (from external/proot) using Android NDK.
- `scripts/build-ioctl-hook.sh` - Builds the `src/ioctlHook.c`, which is used to LD_PRELOAD and override a few ioctls needed by octo4a.
- `scripts/run-android-bootstrap.sh` - Bootstrap's entrypoint script, included as part of the built bootstrap. Executes proot with necessary binds and other parameters.
- `scripts/setup-alpine-rootfs.sh` - Ran during the bootstrap's build process - performs installation of OctoPrint, and setups necessary dependencies inside of the bootstrap.
