# Build checklist (NX669J)

This workspace is an experimental build, not a device-tested kernel. The supplied stock boot image and candidate source now agree on Linux 5.4.147, but their Android release metadata must still be reconciled before treating a package as compatible.

## 1. Confirm firmware match

The supplied `boot.img` uses boot header v3 and contains `5.4.147-qgki-gd9147d4b1b39`; the header says Android 11.0.0 and security patch 2023-06. The pinned branch `tangalbert919/android_kernel_nubia_sm8350:rebase-17200-a12` declares Linux 5.4.147 and includes NX669J configuration fragments. This is a better kernel-source match than the older official source drop, but it does not by itself prove that the uploaded image is the boot image from the user's current Android 12 firmware. Keep releases marked experimental until the full build number and image provenance are confirmed.

## 2. Initialize source

```sh
git clone --recurse-submodules <this-private-repository-url>
cd NX669J-KernelSU-Next-SUSFS
git submodule status
```

The repository pins the device kernel, KernelSU Next (`legacy`), SUSFS LKM source (commit `0e8b944`), AnyKernel3, and AOSP mkbootimg as submodules. Review their license notices before redistributing source or binaries.

## 3. Establish a clean baseline build

The recipe selects Qualcomm's `vendor/lahaina-qgki_defconfig` plus the NX669J GKI diff fragment, and sets `NUBIA_TARGET_PRODUCT=NX669J` so DTS includes resolve to the device's `head.dtsi`. It adds KernelSU Next as a built-in driver, selects the syscall-table hook (the legacy Kconfig warns against its kprobe/tracepoint hook below 5.10), and attempts to build the separately pinned SUSFS guard LKM. A Clang 11 prebuilt is required; set `CLANG_DIR` and run:

```sh
git submodule update --init --depth=1
CLANG_DIR=/path/to/clang-11 JOBS=6 ./scripts/build_kernel.sh
```

Review `dist/build-info.txt` and `dist/kernel.config` after building. The `kernel-5.4` SUSFS patch bundle was checked against this source and did not apply cleanly, so it is not force-applied.

## 4. Integrate KernelSU Next and SUSFS

KernelSU Next is pinned to its `legacy` branch for older-kernel compatibility. The SUSFS LKM source is pinned separately at an exact commit because its former `dev-susfs` branch is no longer advertised upstream. Compilation success does not establish module loadability or SUSFS runtime operation on this vendor kernel.

## 5. Validate before device testing

Compare kernel configuration and boot image components with the exact stock firmware. The supplied `vbmeta.img` has flags `0` and a signed hash descriptor for the original boot image; the package leaves vbmeta unchanged, so an edited boot image will not match the stock AVB descriptor. Preserve the original boot image and a recovery route. Test only on the matching device/firmware; do not distribute an unverified image as ready to flash. See [AVB and firmware warning](AVB-and-firmware.md).

## Current validation gaps

- Exact installed Android version/build number; the uploaded boot header says Android 11.0.0, but the user reports Android 12.
- Build and module compilation results.
- Device boot test, KernelSU manager test, and SUSFS runtime test.
