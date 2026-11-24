# Compilare l'ISO / Build

La build avviene su GitHub Actions (workflow `build-iso`, file `.github/workflows/build-os.yml`)
dentro una macchina virtuale FreeBSD 15.1. Parte a ogni push su `main` o da **Actions → build-iso → Run workflow**.

Lo script `scripts/build-aeternum-iso.sh` scarica base e kernel FreeBSD, installa i pacchetti, copia le immagini da `assets/`
e crea `Aeternum-Security-OS-1.0-amd64.iso` più il file `.sha256`, caricati come artifact `aeternum-security-os-iso`.
Tempo normale: 12–17 minuti.

## Kernel

Il kernel personalizzato si compila con il workflow `build-kernel` (a mano da Actions) e non è ancora usato dall'ISO: vedi `docs/HARDENING.md`.

## Dove modificare le cose

- Programmi installati: `packages/packages-*.txt` (un pacchetto per riga)
- Configurazioni e script del sistema (login, firewall, installatore, avvio): `overlay/`, stessa struttura di `/`
- Immagini e animazione: `assets/`
- Prima di inviare una modifica: `sh tests/check.sh`
