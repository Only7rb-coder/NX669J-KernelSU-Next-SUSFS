#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${DIST_DIR:-$ROOT/dist}"
AK3_DIR="${AK3_DIR:-$ROOT/packaging/AnyKernel3}"
IMAGE="$DIST_DIR/Image"
OUT="$DIST_DIR/NX669J-KernelSU-Next-SUSFS-AnyKernel3.zip"

if [[ ! -f "$IMAGE" || ! -f "$AK3_DIR/tools/ak3-core.sh" ]]; then
  echo "Build the kernel and initialize the AnyKernel3 submodule first." >&2
  exit 2
fi
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp -a "$AK3_DIR/." "$TMP/"
rm -rf "$TMP/.git" "$TMP/.gitmodules"
rm -f "$TMP/README.md" "$TMP/anykernel.sh" "$TMP/Image" "$TMP/Image.gz" "$TMP/Image.gz-dtb" "$TMP/zImage" "$TMP/zImage-dtb"
cp "$IMAGE" "$TMP/Image"

cat > "$TMP/anykernel.sh" <<'AK3'
### NX669J KernelSU Next + SUSFS (experimental) AnyKernel3 installer
properties() { '
kernel.string=NX669J 5.4.147 KernelSU Next + SUSFS (experimental)
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=NX669J
device.name2=nx669j
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; }

# Find boot or the active boot slot; do not modify vbmeta.
BLOCK=boot
IS_SLOT_DEVICE=auto
RAMDISK_COMPRESSION=auto
PATCH_VBMETA_FLAG=0

. tools/ak3-core.sh

dump_boot
# This zip ships only Image; AnyKernel3 preserves the current on-device ramdisk.
write_boot
AK3

cat > "$TMP/README-NX669J.txt" <<'README'
Experimental NX669J boot-kernel package. Device/firmware boot testing has not been performed.

Only use on nubia RedMagic 6 NX669J with a known-good recovery/restore path and the matching 5.4.147 firmware. The supplied source boot.img used during packaging reported Android 11.0.0 / 2023-06 in its header even though the device owner reported Android 12. Verify your exact build before flashing.

The installer checks the device name, writes the active boot partition only, and does not alter vbmeta. Keep a backup of the original boot image. A failed boot may require fastboot/recovery restoration.
README

rm -f "$OUT"
(cd "$TMP" && zip -qr9 "$OUT" .)
sha256sum "$OUT" | tee "$OUT.sha256"
echo "Created $OUT"
