<p align="center">
  <img src="assets/aeternum-logo.png" width="140" alt="Logo di Aeternum Security OS">
</p>

# Aeternum Security OS

**Resilient • Defensive • Hardened**

Questa è la radice del repository sorgente di Aeternum Security OS.

Aeternum Security OS è un sistema operativo live e installabile basato su
FreeBSD 15.1 (amd64), per la sicurezza informatica: penetration test, difesa,
analisi forense e hardening. Include il desktop XFCE, il firewall `pf` attivo
di default e una selezione di strumenti di sicurezza.

**Versione 1.0, prima versione.** Una ISO avviabile viene costruita
automaticamente da GitHub Actions. Prima di installarla, provala in una
macchina virtuale o su un PC di prova.

[Sito e download](https://josephleschajoffical.github.io/AETERNUM/) ·
[English](README.md) · [Roadmap](ROADMAP.it.md) · [Changelog](CHANGELOG.md) ·
[Licenza](LICENSE)

## Mappa dei sorgenti

| Percorso | Descrizione |
| --- | --- |
| `.github` | Workflow CI, modelli per issue e pull request. |
| `assets` | Marchio: logo, scritta, sfondo, icona, animazione di avvio. |
| `docs` | Documentazione di installazione, build e architettura. |
| `kernel` | Configurazione del kernel (`AETERNUM`), vedi [`docs/HARDENING.md`](docs/HARDENING.md) (in inglese). |
| `overlay` | Configurazioni e script installati nell'immagine, con la struttura di `/`. |
| `packages` | Elenchi dei pacchetti installati nell'immagine, uno per riga. |
| `release` | Procedura di rilascio e note di versione. |
| `scripts` | Script di costruzione dell'immagine. |
| `tools` | Script di supporto, es. `verify-iso.sh` per controllare l'ISO con il suo `.sha256`. |
| `tests` | Controlli del repository, con `sh tests/check.sh`. |
| `CHANGELOG.md` | Modifiche per versione. |
| `CODE_OF_CONDUCT.md` | Regole di partecipazione al progetto. |
| `CONTRIBUTING.md` | Linee guida per contribuire. |
| `LICENSE` | Licenza BSD a 2 clausole. |
| `MAINTAINERS` | Chi si occupa di cosa. |
| `NOTICE.md` | Software di terzi, marchi e grafica. |
| `ROADMAP.md` | Lavori previsti, per fase. |
| `SECURITY.md` | Versioni supportate e segnalazione privata di vulnerabilità. |
| `VERSION` | Versione corrente. |
| `index.html` | Sorgente del sito del progetto. |

## Provare l'immagine

1. Scarica l'archivio ISO dal sito; estrai il file `.iso` e il file `.sha256` e verifica il checksum.
2. Scrivi l'immagine su una chiavetta USB da almeno 8 GB con [Rufus](https://rufus.ie) in modalità **Immagine DD**. La chiavetta viene cancellata.
3. Avvia in modalità **UEFI** (disattiva Secure Boot se non parte).
4. La sessione live entra da sola. Credenziali predefinite: `admin` / `admin`.

L'installer su disco, sperimentale e solo UEFI, **cancella il disco scelto**:
provalo prima su una macchina virtuale o un computer di prova. Vedi
[`docs/INSTALL.md`](docs/INSTALL.md).

## Compilazione

L'ISO viene costruita dentro una macchina virtuale FreeBSD 15.1 dal workflow
[`build-iso`](.github/workflows/build-os.yml). Su un host FreeBSD 15.1, come root:

```sh
./scripts/build-aeternum-iso.sh
```

Vedi [`docs/BUILD.md`](docs/BUILD.md) e [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) (in inglese).

## Uso responsabile

Gli strumenti inclusi possono fare danni se usati male. Testa solo sistemi tuoi
o per cui hai un permesso scritto esplicito. Gli autori non rispondono dell'uso
improprio.

## Autore

Aeternum Security OS è stato creato da Zef Lleshaj, sviluppatore, sistemista e tecnico informatico,
qualificato in Cybersecurity.
Sviluppato a Roma, Italia.

## Licenza

Il codice e la documentazione originali sono sotto licenza BSD a 2 clausole.
FreeBSD e i pacchetti della sua ports collection mantengono le proprie
licenze; vedi [NOTICE.md](NOTICE.md). Aeternum Security OS è un progetto
indipendente, non affiliato al FreeBSD Project né alla FreeBSD Foundation.
