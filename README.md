# NX669J KernelSU Next + SUSFS

Experimental build workspace for the **nubia RedMagic 6 (NX669J)**. It pins a public Android 12-era device kernel branch, KernelSU Next, and AnyKernel3 as submodules. It does **not** claim that any image has been boot-tested on the device.

## Compatibility warning

The supplied `boot.img` embeds kernel `5.4.147-qgki-gd9147d4b1b39`; its boot header and signed AVB properties report Android **11.0.0** and security patch **2023-06**. The candidate source branch `tangalbert919/android_kernel_nubia_sm8350:rebase-17200-a12` has Linux 5.4.147 and NX669J config fragments, so its kernel version matches. However, the image metadata conflicts with the user's report of Android 12, and the exact installed build is still unknown. The supplied `vbmeta.img` has verification flags `0` and a signed hash descriptor for the original boot image; this project does not alter vbmeta. Treat all resulting artifacts as experimental and do not assume they will boot with stock AVB enforcement. See [AVB and firmware warning](docs/AVB-and-firmware.md).

## Source layout

- `kernel/`: pinned NX669J-family source submodule (`tangalbert919/android_kernel_nubia_sm8350`, branch `rebase-17200-a12`)
- `integrations/KernelSU-Next/`: pinned KernelSU Next `legacy` branch for older kernels
- `integrations/SUSFS-LKM/`: pinned SUSFS guard module source at commit `0e8b944`
- `packaging/AnyKernel3/`: pinned AnyKernel3 installer framework
- `packaging/mkbootimg/`: AOSP boot-image repack/unpack tools
- `scripts/build_kernel.sh`: build script (requires Android Clang 11)
- `docs/BUILD.md`: build steps, compatibility notes, and validation status

## Status

- [x] Private project repository scaffold
- [x] 5.4.147 NX669J-family source branch pinned as a submodule
- [x] KernelSU Next, SUSFS module source, AnyKernel3, and AOSP mkbootimg pinned
- [x] Read kernel version from supplied stock `boot.img`
- [ ] Confirm exact installed Android build and that the uploaded boot image came from it
- [ ] Complete KernelSU Next + SUSFS module compilation
- [ ] Build and test an image against the exact firmware

## Safety

Keep a copy of the exact stock boot image and a known recovery/restore path before testing. Verify device variant, firmware build, boot image format, AVB/vbmeta requirements, and bootloader state first. Never flash an image built for a different firmware revision.

## Upstream

- Kernel source: <https://github.com/tangalbert919/android_kernel_nubia_sm8350/tree/rebase-17200-a12>
- KernelSU Next: <https://github.com/KernelSU-Next/KernelSU-Next>
- AnyKernel3: <https://github.com/osm0sis/AnyKernel3>
