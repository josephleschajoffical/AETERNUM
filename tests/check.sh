#!/bin/sh
# Controlli rapidi sul repository (nessuna build). Uso: sh tests/check.sh
cd "$(dirname "$0")/.." || exit 1
err=0
fail() { echo "ERRORE: $1"; err=1; }

# 1. File obbligatori
for f in README.md LICENSE VERSION CHANGELOG.md SECURITY.md CONTRIBUTING.md CODE_OF_CONDUCT.md \
         NOTICE.md ROADMAP.md README.it.md ROADMAP.it.md CONTRIBUTING.it.md docs/ARCHITECTURE.md docs/HARDENING.md kernel/AETERNUM overlay/etc/sysctl.conf overlay/boot/loader.conf.local index.html scripts/build-aeternum-iso.sh .github/workflows/build-os.yml \
         assets/aeternum-logo.png assets/aeternum-wallpaper.png assets/aeternum-icon.png \
         assets/aeternum-boot-animation.mp4 packages/packages-required.txt \
         packages/packages-optional.txt packages/packages-security.txt; do
    [ -f "$f" ] || fail "manca $f"
done

# 2. Sintassi degli script (script di build e script dentro overlay/)
for f in scripts/*.sh tests/*.sh tools/*.sh; do
    sh -n "$f" || fail "sintassi non valida: $f"
done
for f in $(find overlay -type f); do
    if head -1 "$f" | grep -q '^#!/bin/sh'; then
        sh -n "$f" || fail "sintassi non valida: $f"
    fi
done

# 3. Ogni file overlay deve esistere e non essere vuoto
for f in $(find overlay -type f); do
    [ -s "$f" ] || fail "file vuoto: $f"
done

# 3a. Pagine di manuale (mdoc): intestazione obbligatoria
for f in $(find overlay -path '*/share/man/man*' -type f); do
    grep -q '^\.Dt ' "$f" && grep -q '^\.Sh NAME' "$f" || fail "pagina man incompleta: $f"
done
for f in overlay/usr/local/share/man/man7/aeternum.7 overlay/usr/local/share/man/man8/aeternum-installer.8 tools/verify-iso.sh release/README.md release/RELNOTES.md; do
    [ -f "$f" ] || fail "manca $f"
done

# 3b. Le immagini del boot loader
for f in aeternum-brand-rev aeternum-brand aeternum-install-brand-rev aeternum-logo-rev; do
    [ -f "overlay/boot/images/$f.png" ] || fail "manca overlay/boot/images/$f.png"
done

# 4. Le liste dei pacchetti non devono essere vuote
for f in packages/*.txt; do
    n=$(grep -v '^[[:space:]]*#' "$f" | grep -c '[^[:space:]]')
    [ "$n" -gt 0 ] || fail "lista vuota: $f"
done

# 5. Gli asset usati dallo script devono esistere
for a in $(grep -o 'ASSETS_DIR}/[A-Za-z0-9._-]*' scripts/build-aeternum-iso.sh | sed 's|ASSETS_DIR}/||' | sort -u); do
    [ -f "assets/$a" ] || fail "asset mancante: assets/$a"
done

# 6. Niente fine riga Windows negli script e nei file di testo
for f in scripts/*.sh tests/*.sh tools/*.sh $(find overlay -type f ! -name '*.png') packages/*.txt; do
    if grep -q "$(printf '\r')" "$f"; then
        fail "fine riga Windows (CRLF) in $f"
    fi
done

[ "$err" -eq 0 ] && echo "Tutti i controlli superati."
exit "$err"
