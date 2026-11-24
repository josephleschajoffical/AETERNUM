# Roadmap

An item is checked only when it is done and verified. [Italiano](ROADMAP.it.md)

## Phase 0 – Foundations
- [x] Name, logo, wordmark, 4K wallpaper, icon and boot animation
- [x] License (BSD-2-Clause)
- [x] Base: FreeBSD 15.1, amd64
- [x] Desktop: XFCE

## Phase 1 – A base that boots
- [x] Build script producing an ISO from FreeBSD (automated on GitHub Actions)
- [ ] Boots in a virtual machine (UEFI)
- [ ] Boots on physical hardware from USB
- [ ] Default user and first boot documented

## Phase 2 – Desktop and branding
- [ ] Desktop configured and verified at boot
- [ ] Wallpaper, icon, boot screen and animation visible in the running system
- [ ] Branded installer

## Phase 3 – Disk installation
- [ ] Guided installation to a physical disk (UEFI), tested
- [ ] Tested on at least two physical machines
- [ ] Interface language selection

## Phase 4 – Security tooling
- [ ] Verified tool list with licenses
- [ ] Antivirus with a simple interface (ClamAV)
- [ ] Hardening baseline

## Phase 5 – First release
- [ ] Release with ISO and SHA-256 checksum
- [ ] Build instructions reproducible by anyone
- [ ] Known issues list

## Future
- 100 interface languages, starting with the main ones
- Hardened kernel profile
- Rollback with ZFS boot environments
- Own package builds and repository, as a full distribution
