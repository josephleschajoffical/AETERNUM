# Architecture

Technical description of the Aeternum Security OS image as built by
`scripts/build-aeternum-iso.sh`. Version 1.0.

## Base system

- FreeBSD 15.1-RELEASE, amd64. Unmodified `base.txz` and `kernel.txz` (GENERIC kernel).
- Downloaded from `download.freebsd.org` with `ftp.freebsd.org` as fallback (30 s timeout, 6 attempts).
- Each archive is verified against the SHA-256 value in the release `MANIFEST`; the build stops on mismatch.
- Packages come from the FreeBSD `pkg` repository at build time. Package versions are therefore not pinned and the image is not bit-for-bit reproducible.

## Image layout

| Item | Value |
| --- | --- |
| File system | ISO 9660 with Rock Ridge, volume label `AETERNUM_OS` |
| Tool | `makefs -t cd9660`, fallback `xorriso` |
| BIOS boot | El Torito, `boot/cdboot`, no emulation |
| UEFI boot | El Torito EFI image `efiboot.img` (FAT, 4 MB) containing `EFI/BOOT/BOOTX64.EFI` (the FreeBSD `loader.efi`) |
| Output | `Aeternum-Security-OS-1.0-amd64.iso` and `.sha256`, about 3 GB |

## Boot

`/boot/loader.conf`:

| Variable | Value |
| --- | --- |
| `loader_brand` | `aeternum` |
| `loader_logo` | `none` |
| `autoboot_delay` | `3` |
| `vfs.root.mountfrom` | `cd9660:/dev/iso9660/AETERNUM_OS` |

The brand is defined in `/boot/lua/brand-aeternum.lua`. It uses the PNG
`/boot/images/aeternum-brand-rev.png` when the console is a framebuffer and
falls back to ASCII art otherwise. The FreeBSD brand files are removed from the
image. The loader draws images at their native size and cannot play
animations; the boot animation runs after login (see below).

## Live mode

- The root file system is the ISO, mounted read-only.
- `/var` (256 MB) and `/tmp` (512 MB) are memory file systems (`varmfs`, `tmpmfs`).
- `/etc/rc.d` script `aeternum_live` (`REQUIRE: tmp var`, `BEFORE: lightdm`) mounts a `tmpfs` on `/home/admin` and fills it from the skeleton in `/usr/local/share/aeternum/skel`.
- Nothing written during a live session persists.

## Services and configuration

| Setting | Value |
| --- | --- |
| Hostname | `aeternum-os` |
| Enabled services | `dbus`, `lightdm`, `pf`, `pflog`, `aeternum_live` |
| Disabled services | `sendmail` |
| Kernel modules | `kld_list="i915kms amdgpu"` (from `drm-kmod`) |
| Display manager | LightDM, automatic login of `admin`, session `xfce` |
| Desktop | XFCE 4 on Xorg |
| Splash | `aeternum-splash` autostart entry plays `boot-animation.mp4` (6 s, 1080p) with `mpv` at login |

All files above live in [`overlay/`](../overlay/) and are copied into the image
tree unchanged.

## Manual pages

Manual pages in mdoc format are installed with the overlay under
`/usr/local/share/man`:

| Page | Subject |
|------|---------|
| `aeternum(7)` | Overview of the system. |
| `aeternum-installer(8)` | Disk installer and its launcher `install-aeternum`. |
| `aeternum_live(8)` | rc.d script of the live session. |
| `aeternum-splash(1)` | Boot animation player. |
| `aeternum-set-wallpaper(1)` | Wallpaper setter. |

## Firewall

`/etc/pf.conf`:

```
set skip on lo0
block in all
pass out all keep state
```

All inbound traffic is blocked; outbound traffic is allowed and tracked.

## Accounts

| Account | Groups | Password |
| --- | --- | --- |
| `root` | | `admin` |
| `admin` | `wheel`, `operator`, `video` | `admin` |

`sudo` is configured for the `wheel` group. These credentials are defaults for
testing.

## Packages

Package names are listed in [`packages/`](../packages/), one per line.

| File | Behaviour on failure |
| --- | --- |
| `packages-required.txt` | The build stops (desktop, Xorg, LightDM, D-Bus, sudo). |
| `packages-optional.txt` | The build continues and lists the missing package (drivers, fonts, applications). |
| `packages-security.txt` | The build continues and lists the missing package (security tools and utilities). |

## Disk installer

`/usr/local/sbin/aeternum-installer`, started from the desktop by
`install-aeternum`. UEFI only. Experimental.

1. Lists disks, excluding `cd*` devices and the live USB drive, and requires the disk name and the word `INSTALLA`.
2. Partitions the disk with GPT:

| Partition | Type | Size | Label | File system |
| --- | --- | --- | --- | --- |
| 1 | `efi` | 260 MB | `aeternum-efi` | FAT32 |
| 2 | `freebsd-ufs` | rest of disk | `aeternum-root` | UFS2 with soft updates |

3. Copies the running system with `tar` through a read-only `nullfs` mount of `/`.
4. Recreates `/var` with `mtree`, writes `/etc/fstab` using the GPT labels, a `loader.conf` with `vfs.root.mountfrom="ufs:/dev/gpt/aeternum-root"` and an `rc.conf` without the memory file systems.
5. Removes the live-mode rc script and the installer icon, then installs `EFI/BOOT/BOOTX64.EFI` on the EFI partition.

## Build pipeline

`scripts/build-aeternum-iso.sh` runs as root on FreeBSD 15.1 and needs network
access and about 25 GB of free space.

| Step | Action |
| --- | --- |
| 1 | Download and verify base and kernel, extract into the image tree. |
| 2 | Remove FreeBSD boot branding. |
| 3 | Create users inside a `chroot`. |
| 4 | Install the desktop packages. |
| 5 | Install the security packages. |
| 6 | Copy `overlay/` and the assets, set file modes. |
| 7 | Build the EFI image and the ISO, write the SHA-256 file. |

## Continuous integration

| Workflow | Purpose |
| --- | --- |
| `build-iso` | Builds the ISO inside FreeBSD 15.1 (`vmactions/freebsd-vm`, 4 GB memory) on `ubuntu-latest` and uploads it as the artifact `aeternum-security-os-iso`. Typical duration 12 to 17 minutes. |
| `check` | Runs `tests/check.sh`: required files, shell syntax, package lists, referenced assets, line endings. |
| `unpack` | Maintenance helper that extracts an uploaded repository archive. |

## Known limitations

- Never booted on physical hardware; installer untested.
- Installer supports UEFI only.
- GENERIC kernel, no hardening profile yet.
- Default credentials are public.
- No antivirus and no translations yet; see [ROADMAP.md](../ROADMAP.md).
