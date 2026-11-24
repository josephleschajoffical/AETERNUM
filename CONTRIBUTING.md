# Contribution Guidelines

Thank you for your interest in Aeternum Security OS. Italian version:
[CONTRIBUTING.it.md](CONTRIBUTING.it.md).

## General contributions

- Open an issue to report a problem or propose an idea, using the templates.
- Improve documentation and translations.
- Test the image and report results, including the hardware or virtual machine used.
- Propose changes to the build script, package lists or system configuration through a pull request.

Report vulnerabilities privately, never in a public issue: see
[SECURITY.md](SECURITY.md). Everyone taking part must follow the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Pull requests

Fork the repository and branch from `main`. Keep each pull request focused on
one change and describe what changes, why, and how you tested it. Be ready to
adjust the change after review.

### Code quality

- Run `sh tests/check.sh` before submitting; it must pass.
- Shell scripts must be POSIX `sh` and pass `sh -n`.
- Follow `.editorconfig`: UTF-8, LF line endings, 4-space indent, no trailing whitespace.
- System files go under `overlay/`, package names under `packages/`, images under `assets/`.

### Commit structure

One logical change per commit. Squash fixups into the commit they fix and
rebase your branch on `main` instead of merging.

### Commit messages

- First line: a short imperative summary, 72 characters or fewer.
- A blank line, then a body explaining what and why, when it is not obvious.
- Reference issues with `Fixes #123` where relevant.
- End with a `Signed-off-by:` line (see below).

### Author information

Commits must carry a real name or a stable pseudonym and a valid email
address. Commit history is permanent.

### Signed-off-by

Add `-s` to `git commit` to sign off. By doing so you certify the
[Developer Certificate of Origin](https://developercertificate.org/): you wrote
the change or have the right to submit it under the project license.

## Quality expectations

Low quality submissions may be closed. Do not submit code you do not have the
right to share or code under an incompatible license. Respond to review
feedback; pull requests without activity for a month may be closed and can be
reopened later.

## License of contributions

Contributions are licensed under the **BSD 2-Clause License**, like
the rest of the project.
