# Firmware identity and AVB warning

The supplied archive's `boot.img` and `vbmeta.img` do **not** identify an Android 12 build. AOSP `avbtool info_image` reports the boot fingerprint as:

`nubia/NX669J/NX669J:11/RKQ1.210614.002/nubia.20230622.002940:user/release-keys`

The boot header is version 3, Android release `11.0.0`, security patch `2023-06-01`, and the kernel string is `5.4.147-qgki-gd9147d4b1b39`. This is consistent with the supplied source's Linux 5.4.147 version, but it does not establish that these images are from the user's currently installed Android 12 build.

The supplied `vbmeta.img` uses `SHA256_RSA4096`, has flags `0`, and contains a signed hash descriptor for the original `boot` partition image. Replacing the kernel changes the boot-image digest. Therefore a repacked `boot.img` will **not** match the supplied stock AVB descriptor. The AnyKernel3 package deliberately leaves `vbmeta` unchanged and does not disable verification.

Do not treat these artifacts as flash-ready on a device that enforces the supplied stock AVB chain. They are experimental kernel-build outputs only. Before device testing, verify the exact installed firmware/build and have a known recovery path. Producing a vbmeta image that disables verification would be a separate security change and is intentionally not done here.
