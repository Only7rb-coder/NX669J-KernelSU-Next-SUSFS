#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL_DIR="${KERNEL_DIR:-$ROOT/kernel}"
KSU_DIR="${KSU_DIR:-$ROOT/integrations/KernelSU-Next}"
SUSFS_DIR="${SUSFS_DIR:-$ROOT/integrations/SUSFS-LKM}"
OUT_DIR="${OUT_DIR:-$ROOT/out}"
DIST_DIR="${DIST_DIR:-$ROOT/dist}"
CLANG_DIR="${CLANG_DIR:-}"
JOBS="${JOBS:-$(nproc)}"

if [[ -z "$CLANG_DIR" || ! -x "$CLANG_DIR/bin/clang" ]]; then
  echo "Set CLANG_DIR to an Android Clang 11 prebuilt directory (must contain bin/clang)." >&2
  exit 2
fi
if [[ ! -d "$KERNEL_DIR/arch/arm64/configs/vendor" || ! -d "$KSU_DIR/kernel" || ! -d "$SUSFS_DIR/kernel/susfs" ]]; then
  echo "Initialize the kernel, KernelSU Next, and SUSFS submodules first." >&2
  exit 2
fi

export PATH="$CLANG_DIR/bin:$PATH"
export ARCH=arm64
export LLVM=1
export LLVM_IAS=1
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export HOSTCC="${HOSTCC:-gcc}"
export NUBIA_TARGET_PRODUCT=NX669J

# Wire the pinned KernelSU Next source into this kernel tree, idempotently.
ln -sfn "$KSU_DIR/kernel" "$KERNEL_DIR/drivers/kernelsu"
grep -q 'obj-.*CONFIG_KSU.*kernelsu/' "$KERNEL_DIR/drivers/Makefile" || \
  printf '\nobj-$(CONFIG_KSU) += kernelsu/\n' >> "$KERNEL_DIR/drivers/Makefile"
grep -q 'source "drivers/kernelsu/Kconfig"' "$KERNEL_DIR/drivers/Kconfig" || \
  sed -i '/^endmenu/i source "drivers/kernelsu/Kconfig"' "$KERNEL_DIR/drivers/Kconfig"

# The selected public 5.4.147 source contains unresolved conflict markers in
# rtc-pm8xxx.c. Apply the small, checked-in repair only when still needed.
if grep -q '^<<<<<<< HEAD$' "$KERNEL_DIR/drivers/rtc/rtc-pm8xxx.c"; then
  git -C "$KERNEL_DIR" apply "$ROOT/patches/0001-resolve-rtc-pm8xxx-conflict.patch"
fi

mkdir -p "$OUT_DIR" "$DIST_DIR"
make -C "$KERNEL_DIR" O="$OUT_DIR" vendor/lahaina-qgki_defconfig
"$KERNEL_DIR/scripts/kconfig/merge_config.sh" -m -O "$OUT_DIR" \
  "$OUT_DIR/.config" \
  "$KERNEL_DIR/arch/arm64/configs/vendor/lahaina-NX669J-GKI_diff" \
  "$ROOT/config/nx669j-ksu.fragment"
make -C "$KERNEL_DIR" O="$OUT_DIR" olddefconfig

# 5.4 requires KernelSU Next built into the kernel. The SUSFS guard LKM is
# built separately from its pinned commit after the kernel exports symbols.
make -C "$KERNEL_DIR" O="$OUT_DIR" ARCH=arm64 LLVM=1 LLVM_IAS=1 \
  CLANG_TRIPLE="$CLANG_TRIPLE" CROSS_COMPILE="$CROSS_COMPILE" \
  CROSS_COMPILE_ARM32="$CROSS_COMPILE_ARM32" HOSTCC="$HOSTCC" \
  -j"$JOBS" Image modules dtbs
make -C "$KERNEL_DIR" O="$OUT_DIR" M="$SUSFS_DIR/kernel/susfs" \
  ARCH=arm64 LLVM=1 LLVM_IAS=1 CLANG_TRIPLE="$CLANG_TRIPLE" \
  CROSS_COMPILE="$CROSS_COMPILE" CROSS_COMPILE_ARM32="$CROSS_COMPILE_ARM32" \
  HOSTCC="$HOSTCC" modules

cp "$OUT_DIR/arch/arm64/boot/Image" "$DIST_DIR/Image"
cp "$SUSFS_DIR/kernel/susfs/susfs_guard_lkm.ko" "$DIST_DIR/susfs_guard_lkm.ko"
cp "$OUT_DIR/.config" "$DIST_DIR/kernel.config"
{
  printf 'kernel_source='; git -C "$KERNEL_DIR" rev-parse HEAD
  printf 'kernelsu_next='; git -C "$KSU_DIR" rev-parse HEAD
  printf 'susfs_source='; git -C "$SUSFS_DIR" rev-parse HEAD
  printf 'clang='; "$CLANG_DIR/bin/clang" --version | head -1
  printf 'kernel_release='; make -s -C "$KERNEL_DIR" O="$OUT_DIR" kernelrelease
} > "$DIST_DIR/build-info.txt"
echo "Build artifacts copied to $DIST_DIR"
