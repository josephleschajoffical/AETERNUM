# release

Release procedure and notes for Aeternum Security OS.

| File | Contents |
|------|----------|
| `RELNOTES.md` | Release notes of the current version. |
| `README.md` | This file: how a release is made. |

## Making a release

1. Update `VERSION` and add the version to `CHANGELOG.md`.
2. Run `sh tests/check.sh`; it must print "Tutti i controlli superati."
3. Run the `build-iso` workflow (Actions) and wait for it to finish. The
   output is the artifact `aeternum-security-os-iso`: the ISO and its
   `.sha256` file.
4. Verify the image: `sh tools/verify-iso.sh Aeternum-Security-OS-<version>-amd64.iso`.
5. Boot the ISO in a virtual machine (UEFI) and on a test PC, and try the
   disk installer.
6. Publish `RELNOTES.md` and the checksum together with the ISO.
