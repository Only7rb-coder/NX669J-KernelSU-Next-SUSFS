# Build checklist (NX669J)

This workspace is a starting point, not a prebuilt kernel. Complete the checks below before adding patches or flashing anything.

## 1. Confirm firmware match

On the phone, record the full model (`NX669J`), Android version, full build number, and kernel version (Settings → About phone; a device-info app or `adb shell uname -a` can provide the kernel string). Confirm that the boot image used for testing comes from that exact firmware build. The public kernel source currently documented here targets Android 11; “latest stock” alone does not establish a match.

## 2. Initialize source

```sh
git clone --recurse-submodules <this-private-repository-url>
cd NX669J-KernelSU-Next-SUSFS
git submodule status
```

The submodule points to the public `ztemt/NX669J-kernel` repository. Review its license and notices before redistributing source or binaries.

## 3. Establish a clean baseline build

Read `kernel/README*` and the vendor build scripts/config fragments. Identify the exact NX669J defconfig and toolchain expected by the matching firmware release. Build the unmodified kernel first and verify the resulting artifacts against the stock boot image. Record compiler versions, config, source revisions, and build commands in the repository before applying patches.

## 4. Integrate KernelSU Next and SUSFS

Choose KernelSU Next and SUSFS commits that explicitly support the kernel tree/version and the desired integration mode. Apply the upstream instructions for that revision; do not assume generic GKI instructions apply to this vendor 5.4 tree. Keep each integration as a separately reviewable commit. Enable only documented, required config options and inspect all patch conflicts.

## 5. Validate before device testing

Compare kernel configuration and boot image components with the exact stock firmware. Preserve the original boot image and a recovery route. Test only on the matching device/firmware; do not distribute an unverified image as ready to flash.

## Current blockers

- Exact Android release/build number for the user's “latest stock” firmware.
- Running kernel version/build string.
- Matching stock boot image and the vendor's full build instructions/toolchain details.
- Verified KernelSU Next and SUSFS patch revisions compatible with this source.
