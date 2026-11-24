# Aeternum Security OS 1.0 - Release Notes

Base: FreeBSD 15.1-RELEASE, amd64. Boot: UEFI only.

## Contents

- XFCE desktop, automatic login in the live session.
- `pf` firewall enabled by default (`/etc/pf.conf`).
- Kernel and network hardening in `/etc/sysctl.conf` and
  `/boot/loader.conf.local`.
- Security tools from the FreeBSD ports collection (`packages/`).
- Disk installer `install-aeternum` (UEFI, GPT, UFS).
- Manual pages: `aeternum(7)`, `aeternum-installer(8)`.

## Accounts

User `admin`, password `admin`. The same password is set for `root`.
Change both after the first login.

## Known limitations

- The image has been built by GitHub Actions; it has not yet been verified on
  physical hardware.
- The kernel is the FreeBSD GENERIC kernel. The hardened kernel in `kernel/`
  is not used by the image yet.
- Additional languages and the antivirus (ClamAV) are not included.
- Secure Boot must be disabled.

## Checksum

See the `.sha256` file shipped with the ISO.
