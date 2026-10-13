# Source and compatibility notes

This note records the upstream references used for the experimental NX669J build.

- The original public Nubia source repository describes itself as NX669J Android 11 source. Its checked-out `msm-5.4` Makefile reports Linux 5.4.61: <https://github.com/ztemt/NX669J-kernel>.
- The candidate device-family tree is `tangalbert919/android_kernel_nubia_sm8350`, branch `rebase-17200-a12`, commit `4c1ad9dc4552e56e43032cc9f218d229298cdf72`. Its Makefile reports Linux 5.4.147 and its configs include `lahaina-NX669J-GKI_diff`: <https://github.com/tangalbert919/android_kernel_nubia_sm8350/tree/rebase-17200-a12>.
- KernelSU Next's compatibility documentation says it supports Android kernels 4.4 through 6.12 and requires a built-in driver for the 4.19–5.4 GKI 1.0 range: <https://github.com/KernelSU-Next/KernelSU-Next/blob/dev/docs/README.md>.
- KernelSU Next's non-GKI guide covers older-kernel integration: <https://kernelsu-next.github.io/webpage/pages/how-to-integrate-for-non-gki.html>. The pinned `legacy` branch Kconfig warns that its kprobe/tracepoint hook should not be used below 5.10; this build selects `KSU_SYSCALL_TABLE_HOOK` instead.
- The SUSFS LKM source was pinned at commit `0e8b9446d1ab32685bcbdffc824251e8faf686e2`, which introduced its `kernel/susfs` module tree: <https://github.com/KernelSU-Next/KernelSU-Next/commit/0e8b9446d1ab32685bcbdffc824251e8faf686e2>. The former `dev-susfs` branch is no longer advertised, so the project pins the commit SHA directly.
- The SUSFS `kernel-5.4` patch branch warns that patches vary across kernels, and its README gives GKI-specific patch instructions: <https://gitlab.com/simonpunk/susfs4ksu/-/tree/kernel-5.4>. A dry-run of those patches against the selected Nubia source reported numerous context/file mismatches, so that patch set is not force-applied.
- The Android Clang 11.0.2 build matching the stock kernel's reported compiler revision is listed as `clang-r383902b1`, build 6877366: <https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/225d2925136a2268ac95a97db4e90d33043b18b9/clang-r383902b1/bin/llvm-objdump>.

## User-provided image observation

The supplied archive contained `boot.img`, `vendor_boot.img`, and `vbmeta.img`. The `boot.img` header is Android boot v3 and reports Android 11.0.0 / security patch 2023-06; its kernel identifies as `5.4.147-qgki-gd9147d4b1b39`, built by nubia with Clang 11.0.2 based on r383902b1. This does not match the user's statement that the installed OS is Android 12, so artifacts made from this input remain experimental until provenance is confirmed.
