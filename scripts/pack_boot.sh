#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOCK_BOOT_IMG="${STOCK_BOOT_IMG:-}"
KERNEL_IMAGE="${KERNEL_IMAGE:-$ROOT/dist/Image}"
DIST_DIR="${DIST_DIR:-$ROOT/dist}"
MKBOOTIMG_DIR="${MKBOOTIMG_DIR:-$ROOT/packaging/mkbootimg}"

if [[ -z "$STOCK_BOOT_IMG" || ! -f "$STOCK_BOOT_IMG" ]]; then
  echo "Set STOCK_BOOT_IMG to the exact stock boot.img to preserve its ramdisk/header." >&2
  exit 2
fi
if [[ ! -f "$KERNEL_IMAGE" || ! -f "$MKBOOTIMG_DIR/unpack_bootimg.py" || ! -f "$MKBOOTIMG_DIR/mkbootimg.py" ]]; then
  echo "Kernel image or AOSP mkbootimg tools are missing; build first and initialize submodules." >&2
  exit 2
fi

mkdir -p "$DIST_DIR"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/original" "$TMP/repacked"

python3 - "$STOCK_BOOT_IMG" <<'PY'
import struct,sys
b=open(sys.argv[1],'rb').read(44)
if b[:8] != b'ANDROID!':
    raise SystemExit('Input is not an Android boot image')
version=struct.unpack_from('<I',b,40)[0]
if version != 3:
    raise SystemExit(f'Expected Android boot header v3, found v{version}')
print('Stock boot header v3 verified')
PY

python3 "$MKBOOTIMG_DIR/unpack_bootimg.py" \
  --boot_img "$STOCK_BOOT_IMG" --out "$TMP/original" --format=mkbootimg > "$TMP/args"
python3 - "$MKBOOTIMG_DIR/mkbootimg.py" "$TMP/args" "$KERNEL_IMAGE" "$DIST_DIR/boot.img" <<'PY'
import pathlib,shlex,subprocess,sys
mkbootimg,args_file,kernel,out=sys.argv[1:]
args=shlex.split(pathlib.Path(args_file).read_text())
for i,arg in enumerate(args):
    if arg == '--kernel':
        args[i+1]=kernel
        break
else:
    raise SystemExit('Unpacked boot metadata did not include a kernel argument')
subprocess.run([sys.executable,mkbootimg,*args,'--output',out],check=True)
PY

python3 "$MKBOOTIMG_DIR/unpack_bootimg.py" \
  --boot_img "$DIST_DIR/boot.img" --out "$TMP/repacked" --format=info > "$TMP/repacked-info.txt"
python3 - "$TMP/original/ramdisk" "$TMP/repacked/ramdisk" <<'PY'
import hashlib,sys
hashes=[hashlib.sha256(open(p,'rb').read()).hexdigest() for p in sys.argv[1:]]
if hashes[0] != hashes[1]:
    raise SystemExit('Ramdisk changed during repack; refusing to keep the image')
print('Ramdisk SHA-256 preserved:',hashes[0])
PY
sha256sum "$DIST_DIR/boot.img" | tee "$DIST_DIR/boot.img.sha256"
printf '\nRepacked metadata:\n'; cat "$TMP/repacked-info.txt"
