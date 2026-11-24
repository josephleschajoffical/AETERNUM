# Roadmap

Una voce è spuntata solo quando è fatta e verificata. [English](ROADMAP.md)

## Fase 0 – Fondamenta
- [x] Nome, logo, scritta, sfondo 4K, icona e animazione di avvio
- [x] Licenza (BSD-2-Clause)
- [x] Base: FreeBSD 15.1, amd64
- [x] Desktop: XFCE

## Fase 1 – Una base che si avvia
- [x] Script che costruisce un'ISO da FreeBSD (automatico su GitHub Actions)
- [ ] Si avvia in una macchina virtuale (UEFI)
- [ ] Si avvia su un computer reale da USB
- [ ] Utente predefinito e primo avvio documentati

## Fase 2 – Desktop e marchio
- [ ] Desktop configurato e verificato all'avvio
- [ ] Sfondo, icona, schermata di avvio e animazione visibili nel sistema
- [ ] Installer con marchio Aeternum

## Fase 3 – Installazione su disco
- [ ] Installazione guidata su disco reale (UEFI), provata
- [ ] Provata su almeno due computer reali
- [ ] Scelta della lingua dell'interfaccia

## Fase 4 – Strumenti di sicurezza
- [ ] Elenco strumenti verificato, con licenze
- [ ] Antivirus con interfaccia semplice (ClamAV)
- [ ] Hardening di base

## Fase 5 – Prima release
- [ ] Release con ISO e checksum SHA-256
- [ ] Istruzioni di build ripetibili da chiunque
- [ ] Elenco dei problemi noti

## Futuro
- 100 lingue, si parte dalle principali
- Profilo kernel irrobustito
- Ritorno a versioni precedenti con boot environments ZFS
- Pacchetti e repository propri, come una distribuzione completa
