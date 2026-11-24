#!/bin/sh
# Verify an Aeternum ISO against its .sha256 file.
# Usage: sh tools/verify-iso.sh Aeternum-Security-OS-1.0-amd64.iso
# Works on FreeBSD (sha256) and Linux/macOS (sha256sum, shasum).

iso="$1"
[ -n "$iso" ] && [ -f "$iso" ] || { echo "usage: $0 file.iso" >&2; exit 2; }
sumfile="${iso}.sha256"
[ -f "$sumfile" ] || { echo "missing $sumfile" >&2; exit 2; }

# The .sha256 file holds "SHA256 (name) = <hash>".
expected="$(sed -n 's/.*= *\([0-9a-fA-F]\{64\}\).*/\1/p' "$sumfile" | head -1)"
[ -n "$expected" ] || { echo "cannot read hash from $sumfile" >&2; exit 2; }

if command -v sha256 >/dev/null 2>&1; then
    actual="$(sha256 -q "$iso")"
elif command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$iso" | cut -d' ' -f1)"
else
    actual="$(shasum -a 256 "$iso" | cut -d' ' -f1)"
fi

if [ "$actual" = "$expected" ]; then
    echo "OK: $iso"
else
    echo "FAILED: checksum mismatch for $iso" >&2
    exit 1
fi
