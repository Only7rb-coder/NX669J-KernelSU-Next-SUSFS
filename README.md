# NX669J KernelSU Next + SUSFS

Experimental build workspace for the **nubia RedMagic 6 (NX669J)**. This repo tracks the publicly released NX669J kernel as a Git submodule and documents the integration workflow. It does **not** claim to provide a tested or flashable image.

## Compatibility warning

The public `ztemt/NX669J-kernel` source identifies itself as an **Android 11** source tree and contains Qualcomm **lahaina** / NX669J configuration fragments. The device owner reported using the latest stock firmware, but its exact Android build and kernel version have not yet been confirmed. Do not build or flash based on the model name alone: mismatched kernel/boot images can prevent the phone from booting.

## Source layout

- `kernel/`: pinned upstream source submodule (`ztemt/NX669J-kernel`, branch `main`)
- `docs/BUILD.md`: safe, reproducible build checklist and outstanding compatibility checks

## Status

- [x] Private project repository scaffold
- [x] Public upstream source pinned as a submodule
- [ ] Confirm exact stock Android build and running kernel version
- [ ] Confirm matching stock boot image and build toolchain
- [ ] Integrate compatible KernelSU Next revision
- [ ] Integrate compatible SUSFS revision and configuration
- [ ] Build and test an image against the exact firmware

## Safety

Keep a copy of the exact stock boot image and a known recovery/restore path before testing. Verify device variant, firmware build, boot image format, AVB/vbmeta requirements, and bootloader state first. Never flash an image built for a different firmware revision.

## Upstream

- Kernel source: <https://github.com/ztemt/NX669J-kernel>
- KernelSU Next: <https://github.com/KernelSU-Next/KernelSU-Next>
- SUSFS: <https://github.com/sidex15/susfs4ksu>
