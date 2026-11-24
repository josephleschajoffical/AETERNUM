#!/bin/sh
# ==============================================================================
# AETERNUM SECURITY OS - ISO builder (FreeBSD, amd64)
#
# Eseguire su FreeBSD 15.1 (anche in VM), come root, con rete e almeno 25 GB
# liberi. Lo script legge le immagini da ../assets e i file di sistema da
# ../overlay e ../packages (vedi docs/ARCHITECTURE.md).
# ==============================================================================
set -e

ARCH="amd64"
FREEBSD_VER="15.1-RELEASE"
BASE_URL="https://download.freebsd.org/releases/${ARCH}/${FREEBSD_VER}"
WORK_DIR="/var/tmp/aeternum-build"
ISO_ROOT="${WORK_DIR}/iso"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Il repository ha questa struttura: scripts/ (questo file), assets/ (immagini e video)
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ASSETS_DIR="${REPO_DIR}/assets"
OUTPUT_ISO="${REPO_DIR}/Aeternum-Security-OS-1.0-${ARCH}.iso"

if [ "$(id -u)" -ne 0 ]; then
    echo "Errore: eseguire come root." >&2
    exit 1
fi

cleanup() {
    umount "${ISO_ROOT}/proc" 2>/dev/null || true
    umount "${ISO_ROOT}/dev" 2>/dev/null || true
}
trap cleanup EXIT

# ------------------------------------------------------------------------------
echo ">>> [1/7] Download e verifica base system e kernel (${FREEBSD_VER})..."
rm -rf "${WORK_DIR}"
mkdir -p "${ISO_ROOT}"

# Download con timeout e tentativi su piu' server: se uno si blocca, si prova l'altro.
BASE_URLS="${BASE_URL} https://ftp.freebsd.org/pub/FreeBSD/releases/${ARCH}/${FREEBSD_VER}"
dl() {
    f="$1"
    n=0
    while [ "${n}" -lt 6 ]; do
        for u in ${BASE_URLS}; do
            echo "    scarico ${f} da ${u} (tentativo $((n + 1)))..."
            if fetch -T 30 -o "${WORK_DIR}/${f}" "${u}/${f}"; then
                return 0
            fi
        done
        n=$((n + 1))
        sleep 5
    done
    echo "Errore: impossibile scaricare ${f} dopo vari tentativi." >&2
    return 1
}
for f in base.txz kernel.txz MANIFEST; do
    dl "${f}"
done

for f in base.txz kernel.txz; do
    expected="$(awk -v f="${f}" '$1 == f { print $2; exit }' "${WORK_DIR}/MANIFEST")"
    actual="$(sha256 -q "${WORK_DIR}/${f}")"
    if [ -z "${expected}" ]; then
        echo "Errore: hash di ${f} non trovato in MANIFEST." >&2
        exit 1
    fi
    if [ "${expected}" != "${actual}" ]; then
        echo "Errore: checksum di ${f} NON corrisponde. Scarico interrotto." >&2
        exit 1
    fi
    echo "    checksum ok: ${f}"
done

tar -xpf "${WORK_DIR}/base.txz" -C "${ISO_ROOT}"
tar -xpf "${WORK_DIR}/kernel.txz" -C "${ISO_ROOT}"

# File per l'installer su disco (bsdinstall li cerca in /usr/freebsd-dist)
mkdir -p "${ISO_ROOT}/usr/freebsd-dist"
cp -f "${WORK_DIR}/base.txz" "${WORK_DIR}/kernel.txz" "${WORK_DIR}/MANIFEST" \
    "${ISO_ROOT}/usr/freebsd-dist/"

# ------------------------------------------------------------------------------
echo ">>> [2/7] Boot logo Aeternum e identita' del sistema..."
rm -f "${ISO_ROOT}/boot/lua/brand-fbsd.lua" \
      "${ISO_ROOT}/boot/lua/logo-orb.lua" \
      "${ISO_ROOT}/boot/lua/logo-beastie.lua" \
      "${ISO_ROOT}/boot/lua/logo-beastiebw.lua"

# Via le immagini FreeBSD del bootloader; quelle Aeternum arrivano dalla cartella overlay/boot/images
rm -f "${ISO_ROOT}"/boot/images/freebsd*.png
mkdir -p "${ISO_ROOT}/boot/images"




# ------------------------------------------------------------------------------
echo ">>> [3/7] Utenti (admin / admin - SOLO per prova, da cambiare)..."
mount -t devfs devfs "${ISO_ROOT}/dev"
mkdir -p "${ISO_ROOT}/proc"
mount -t procfs proc "${ISO_ROOT}/proc"
cp -f /etc/resolv.conf "${ISO_ROOT}/etc/resolv.conf"

chroot "${ISO_ROOT}" /bin/sh <<'CHEOF'
set -e
echo 'admin' | pw usermod root -h 0
pw useradd admin -m -G wheel,operator,video -s /bin/sh -c "Aeternum User"
echo 'admin' | pw usermod admin -h 0
CHEOF

# ------------------------------------------------------------------------------
echo ">>> [4/7] Desktop XFCE, driver grafici e font..."
cp -f "${REPO_DIR}"/packages/*.txt "${ISO_ROOT}/tmp/"
# Parte indispensabile: se fallisce, lo script si ferma.
chroot "${ISO_ROOT}" /bin/sh <<'CHEOF'
set -e
env ASSUME_ALWAYS_YES=yes pkg bootstrap -f
pkg update -f
pkg install -y $(grep -v '^[[:space:]]*#' /tmp/packages-required.txt)
mkdir -p /usr/local/etc/sudoers.d
echo '%wheel ALL=(ALL:ALL) ALL' > /usr/local/etc/sudoers.d/wheel
CHEOF

# Parte opzionale: un pacchetto che non esiste NON ferma lo script.
chroot "${ISO_ROOT}" /bin/sh <<'CHEOF'
for p in $(grep -v '^[[:space:]]*#' /tmp/packages-optional.txt); do
    pkg install -y "$p" || echo "$p" >> /var/log/aeternum-missing-packages.txt
done
CHEOF

# ------------------------------------------------------------------------------
echo ">>> [5/7] Strumenti di cybersecurity..."
chroot "${ISO_ROOT}" /bin/sh <<'CHEOF'
for p in $(grep -v '^[[:space:]]*#' /tmp/packages-security.txt); do
    pkg install -y "$p" || echo "$p" >> /var/log/aeternum-missing-packages.txt
done
pkg clean -a -y
rm -f /tmp/packages-*.txt
CHEOF
umount "${ISO_ROOT}/proc"
umount "${ISO_ROOT}/dev"

if [ -f "${ISO_ROOT}/var/log/aeternum-missing-packages.txt" ]; then
    echo ">>> ATTENZIONE: pacchetti NON installati (nome inesistente o non disponibile):"
    sed 's/^/      - /' "${ISO_ROOT}/var/log/aeternum-missing-packages.txt"
fi

# ------------------------------------------------------------------------------
echo ">>> [6/7] Modalita' live, installer e grafica Aeternum..."
SKEL="${ISO_ROOT}/usr/local/share/aeternum/skel"
mkdir -p "${SKEL}/Desktop" "${SKEL}/.config/autostart" \
         "${ISO_ROOT}/usr/local/share/pixmaps" \
         "${ISO_ROOT}/usr/local/share/backgrounds/aeternum" \
         "${ISO_ROOT}/usr/local/etc/lightdm" \
         "${ISO_ROOT}/usr/local/etc/rc.d" \
         "${ISO_ROOT}/usr/local/bin"

copy_asset() {
    if [ -f "$1" ]; then
        cp -f "$1" "$2"
    else
        echo "AVVISO: file mancante: $1" >&2
    fi
}
copy_asset "${ASSETS_DIR}/aeternum-logo.png" \
    "${ISO_ROOT}/usr/local/share/pixmaps/aeternum-logo.png"
copy_asset "${ASSETS_DIR}/aeternum-wallpaper.png" \
    "${ISO_ROOT}/usr/local/share/backgrounds/aeternum/aeternum-wallpaper.png"
# Icona Aeternum (scudo di cristallo) e animazione di avvio: file opzionali nel repository
mkdir -p "${ISO_ROOT}/usr/local/share/icons/hicolor/48x48/apps" \
         "${ISO_ROOT}/usr/local/share/icons/hicolor/512x512/apps" \
         "${ISO_ROOT}/usr/local/share/aeternum"
copy_asset "${ASSETS_DIR}/aeternum-icon.png" \
    "${ISO_ROOT}/usr/local/share/pixmaps/aeternum-icon.png"
copy_asset "${ASSETS_DIR}/aeternum-icon.png" \
    "${ISO_ROOT}/usr/local/share/icons/hicolor/512x512/apps/aeternum.png"
copy_asset "${ASSETS_DIR}/aeternum-boot-animation.mp4" \
    "${ISO_ROOT}/usr/local/share/aeternum/boot-animation.mp4"
# Icona del menu applicazioni di XFCE: se manca l'icona, resta il logo
if [ -f "${ASSETS_DIR}/aeternum-icon.png" ]; then
    MENU_ICON="${ASSETS_DIR}/aeternum-icon.png"
else
    MENU_ICON="${ASSETS_DIR}/aeternum-logo.png"
fi
copy_asset "${MENU_ICON}" \
    "${ISO_ROOT}/usr/local/share/pixmaps/xfce4_xicon1.png"
copy_asset "${MENU_ICON}" \
    "${ISO_ROOT}/usr/local/share/icons/hicolor/48x48/apps/xfce4-panel-menu.png"

# Copia l'overlay (dopo l'installazione dei pacchetti): tutti i file di configurazione e gli script del sistema
# (cartella overlay/ del repository, stessa struttura di / nel sistema)
cp -R "${REPO_DIR}/overlay/." "${ISO_ROOT}/"

# Animazione all'ingresso nel desktop (parte da sola; se manca il video o mpv, non fa nulla)
chmod +x "${ISO_ROOT}/usr/local/bin/aeternum-splash"

# Sfondo: impostato all'avvio della sessione per tutti i monitor
chmod +x "${ISO_ROOT}/usr/local/bin/aeternum-set-wallpaper"


# Auto-login dell'utente admin nel desktop live

# Installer su disco
chmod +x "${ISO_ROOT}/usr/local/bin/install-aeternum"

# Installatore: copia sul disco il sistema COMPLETO (desktop e strumenti inclusi), solo UEFI
mkdir -p "${ISO_ROOT}/usr/local/sbin"
chmod 555 "${ISO_ROOT}/usr/local/sbin/aeternum-installer"

chmod +x "${SKEL}/Desktop/Installa-Aeternum-OS.desktop"
if [ -f "${ISO_ROOT}/usr/local/share/pixmaps/aeternum-icon.png" ]; then
    sed -i '' 's|aeternum-logo.png|aeternum-icon.png|' "${SKEL}/Desktop/Installa-Aeternum-OS.desktop"
fi

# Il disco e' di sola lettura: la home di admin vive in RAM (tmpfs) ad ogni avvio
chmod 555 "${ISO_ROOT}/usr/local/etc/rc.d/aeternum_live"

# /var e /tmp in RAM con il meccanismo standard di FreeBSD


# Firewall di base: tutto in uscita, niente in ingresso non richiesto

# ------------------------------------------------------------------------------
echo ">>> [7/7] Creazione ISO avviabile (UEFI + BIOS)..."
# Immagine EFI (avvio UEFI). Primo tentativo: makefs. Se va in crash, uso mtools.
EFI_STAGE="${WORK_DIR}/efi_stage"
EFI_IMG="${WORK_DIR}/efiboot.img"
mkdir -p "${EFI_STAGE}/EFI/BOOT"
cp "${ISO_ROOT}/boot/loader.efi" "${EFI_STAGE}/EFI/BOOT/BOOTX64.EFI"
if ! makefs -t msdos -o fat_type=12 -o sectors_per_cluster=4 \
        -o volume_label=EFISYS -s 4m "${EFI_IMG}" "${EFI_STAGE}"; then
    echo ">>> makefs msdos non funziona qui, provo con mtools..."
    rm -f "${EFI_IMG}"
    env ASSUME_ALWAYS_YES=yes pkg install -y mtools
    truncate -s 4m "${EFI_IMG}"
    mformat -i "${EFI_IMG}" -t 64 -h 4 -s 32 -v EFISYS ::
    mmd -i "${EFI_IMG}" ::/EFI ::/EFI/BOOT
    mcopy -i "${EFI_IMG}" "${EFI_STAGE}/EFI/BOOT/BOOTX64.EFI" ::/EFI/BOOT/BOOTX64.EFI
fi

echo ">>> Dimensione del contenuto e spazio libero:"
du -sh "${ISO_ROOT}" || true
df -h "${WORK_DIR}" || true

TMP_ISO="${WORK_DIR}/aeternum.iso"
if ! makefs -t cd9660 -o rockridge -o label="AETERNUM_OS" \
        -o bootimage="i386;${ISO_ROOT}/boot/cdboot" \
        -o no-emul-boot \
        -o bootimage="i386;${EFI_IMG}" \
        -o no-emul-boot -o platformid=efi \
        "${TMP_ISO}" "${ISO_ROOT}"; then
    echo ">>> makefs cd9660 non funziona qui, provo con xorriso..."
    rm -f "${TMP_ISO}"
    env ASSUME_ALWAYS_YES=yes pkg install -y xorriso
    cp -f "${EFI_IMG}" "${ISO_ROOT}/boot/efiboot.img"
    xorriso -as mkisofs -iso-level 3 -R -V "AETERNUM_OS" \
        -b boot/cdboot -no-emul-boot \
        -eltorito-alt-boot -e boot/efiboot.img -no-emul-boot \
        -o "${TMP_ISO}" "${ISO_ROOT}"
fi
mv -f "${TMP_ISO}" "${OUTPUT_ISO}"

sha256 "${OUTPUT_ISO}" > "${OUTPUT_ISO}.sha256"

echo ">>> FATTO: ${OUTPUT_ISO}"
echo ">>> Prima di dirlo 'pronto': provalo su un PC vero (da USB con Ventoy)."
echo ">>> Ricorda: admin/admin e' solo per prova."
echo ">>> L'installer su disco (icona sul desktop) copia il sistema completo."
