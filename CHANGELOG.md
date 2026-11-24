# Changelog

Formato basato su [Keep a Changelog](https://keepachangelog.com/it/1.1.0/).

## [1.0] – Prima versione

### Aggiunto
- `release/`: procedura di rilascio e note di versione
- Pagine di manuale (`aeternum(7)`, `aeternum-installer(8)`, `aeternum_live(8)`, `aeternum-splash(1)`, `aeternum-set-wallpaper(1)`) in `overlay/usr/local/share/man`
- `tools/verify-iso.sh`: controllo dell'ISO con il file `.sha256`
- Licenza BSD a 2 clausole (al posto della GPL v3)
- Base FreeBSD 15.1 amd64, ISO avviabile UEFI generata da GitHub Actions
- Desktop XFCE con login automatico, utente `admin` / password `admin`
- Firewall `pf` attivo, ambiente live in memoria
- Installatore su disco (`install-aeternum`, solo UEFI) — da collaudare
- Immagine di avvio (nuovo disegno, in `overlay/boot/images/`), logo, sfondo 4K, icona, animazione di avvio
- Struttura del repository: `assets/`, `scripts/`, `docs/`, `.github/`, `overlay/` (configurazioni del sistema), `packages/` (elenchi pacchetti), `tests/`
- Controllo automatico `check` a ogni push, `.editorconfig`, `.gitattributes`, `MAINTAINERS`
- Sito: https://josephleschajoffical.github.io/AETERNUM/

### Aggiunto (protezione)
- Configurazione del kernel `kernel/AETERNUM`, workflow `build-kernel`, `sysctl.conf` e `loader.conf.local` di hardening, `docs/HARDENING.md`

### Modificato
- Motto: **Resilient • Defensive • Hardened** (prima: Offensive • Defensive • Hardened), nel sito, nelle immagini e nell'animazione di avvio
- Marchio unificato: scudo di cristallo in logo, scritta, icona, immagini del boot loader e animazione (6 s)

### Non ancora fatto
- Antivirus, 100 lingue, scelta tra base / desktop / completo, collaudo su PC reale
