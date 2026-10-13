# NX669J KernelSU Next + SUSFS

Experimental build workspace for the **nubia RedMagic 6 (NX669J)**. This repo tracks the publicly released NX669J kernel as a Git submodule and documents the integration workflow. It does **not** claim to provide a tested or flashable image.

## Compatibility warning

The supplied stock `boot.img` has an Android boot v3 header and embeds kernel `5.4.147-qgki-gd9147d4b1b39` (nubia build, Clang 11.0.2). The public `ztemt/NX669J-kernel` source identifies itself as an **Android 11** source tree; its Makefile is Linux **5.4.61**. This is a material source-version mismatch, so this workspace does **not** currently have a matching source tree for that stock image. Do not build or flash based on the model name alone: mismatched kernel/boot images can prevent the phone from booting.

## Source layout

- `kernel/`: pinned upstream source submodule (`ztemt/NX669J-kernel`, branch `main`)
- `docs/BUILD.md`: safe, reproducible build checklist and outstanding compatibility checks

## Status

- [x] Private project repository scaffold
- [x] Public upstream source pinned as a submodule
- [x] Read kernel version from supplied stock `boot.img`
- [ ] Confirm exact stock Android build number / firmware package
- [ ] Obtain kernel source matching the supplied 5.4.147-qgki firmware
- [ ] Integrate compatible KernelSU Next revision
- [ ] Integrate compatible SUSFS revision and configuration
- [ ] Build and test an image against the exact firmware

## Safety

Keep a copy of the exact stock boot image and a known recovery/restore path before testing. Verify device variant, firmware build, boot image format, AVB/vbmeta requirements, and bootloader state first. Never flash an image built for a different firmware revision.

## Upstream

- Kernel source: <https://github.com/ztemt/NX669J-kernel>
- KernelSU Next: <https://github.com/KernelSU-Next/KernelSU-Next>
- SUSFS: <https://github.com/sidex15/susfs4ksu>
