# Hardening

Security configuration of Aeternum Security OS, in three layers. Status:
prepared, **not yet booted** and the kernel **not yet built**. Everything here
is meant to be validated step by step, because aggressive settings applied all
at once make it impossible to tell what broke a system that has never booted.

## Layers

| Layer | File | When it applies |
| --- | --- | --- |
| Kernel | [`kernel/AETERNUM`](../kernel/AETERNUM) | Compiled into the kernel binary. |
| Loader | [`overlay/boot/loader.conf.local`](../overlay/boot/loader.conf.local) | Before the kernel starts. |
| System | [`overlay/etc/sysctl.conf`](../overlay/etc/sysctl.conf) | At every boot, as root. |

The loader and system files are part of the image and are copied to the
installed system. The kernel file is not used by the ISO build yet (see below).

## Differences from the first draft

The first draft of these settings was checked against the FreeBSD source tree.
What changed, and why:

| Draft | Result |
| --- | --- |
| `device pf`, `pflog` | Kept: they are not in GENERIC, so they are really added. `pfsync` dropped (single machine). |
| `options MAC` | Removed: already in GENERIC. |
| `device crypto`, `device aesni`, `options AUDIT` | Removed: already in GENERIC. |
| `options IPSEC` | Kept, with `nooptions IPSEC_SUPPORT`: GENERIC has IPSEC_SUPPORT (IPsec as a loadable module), not IPSEC. |
| `options TCP_SIGNATURE` | Dropped: RFC 2385 TCP-MD5 is used for BGP and adds code without benefit here. |
| `MAC_BIBA`, `MAC_MLS` | Dropped for now: they enforce labels everywhere and make a system unusable unless labelling is designed and tested first. |
| `MAC_BSDEXTENDED`, `MAC_PORTACL`, `MAC_SEEOTHERUIDS` | Kept: no effect until rules are configured. |
| `nooptions COMPAT_FREEBSD4` to `13` | Kept. `COMPAT_FREEBSD32`, `14` and `15` stay. |
| `machdep.mitigations.mds.enable` | Does not exist: the node is `machdep.mitigations.mds.disable`. Left at its automatic default, which already enables the mitigation on affected CPUs. |
| `machdep.mitigations.taa.enable`, `rngds.enable` | Exist; moved to `sysctl.conf`. |
| `kern.elf64.aslr.*` | 64-bit ASLR is already on by default; only 32-bit ASLR is a real change. |
| `kern.elf64.allow_wx=0` | Moved to the STRICT block: it refuses programs with writable and executable segments and can break software. |
| `security.bsd.unprivileged_proc_debug=0` | Moved to the STRICT block: it also stops `gdb` for normal users. |
| `zfs_load`, `aesni_load` | Dropped: ZFS is not used yet; `aesni` is already built into GENERIC. |
| `security.bsd.suser_enabled=1`, `vfs.usermount=0` | Dropped: they are already the defaults. |
| `kern.geom.eli.visible_passphrase`, `security.bsd.allow_destructive_dtrace` | Dropped: not confirmed in the source; can be added after testing on a running system. |

A sysctl name that does not exist only prints an error at boot and is
otherwise harmless.

## Building the custom kernel

Building a kernel needs the FreeBSD sources (`src.txz`) and takes much longer
than the rest of the image. The plan:

1. The `build-kernel` workflow builds `AETERNUM` in a FreeBSD 15.1 virtual machine on demand and uploads the result as an artifact. A kernel configuration error shows up there, without touching the ISO build.
2. Once the kernel builds, the ISO build uses it in place of the stock kernel.
3. The ISO is then tested; only after it boots are the STRICT settings enabled one at a time.

## Not covered yet

- `kern.securelevel`, which prevents loading kernel modules after boot, breaks the graphical session unless set up carefully.
- Mandatory labelling (MAC Biba / MLS).
- Full-disk encryption with GELI in the installer.
- Audit rules (`auditd`).
