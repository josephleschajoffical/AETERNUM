# Linee guida per contribuire

Grazie per l'interesse in Aeternum Security OS. English version:
[CONTRIBUTING.md](CONTRIBUTING.md).

## Contributi in generale

- Apri una issue per segnalare un problema o proporre un'idea, usando i modelli.
- Migliora la documentazione e le traduzioni.
- Prova l'immagine e riporta i risultati, indicando hardware o macchina virtuale.
- Proponi modifiche allo script di build, agli elenchi dei pacchetti o alla configurazione con una pull request.

Le vulnerabilità vanno segnalate in privato, mai in una issue pubblica: vedi
[SECURITY.md](SECURITY.md). Chi partecipa deve rispettare il
[Codice di condotta](CODE_OF_CONDUCT.md).

## Pull request

Fai un fork e crea un ramo da `main`. Una modifica per pull request, con
descrizione di cosa cambia, perché e come l'hai provata. Sii pronto a
correggere dopo la revisione.

### Qualità del codice

- Esegui `sh tests/check.sh` prima di inviare: deve passare.
- Gli script shell devono essere POSIX `sh` e superare `sh -n`.
- Segui `.editorconfig`: UTF-8, fine riga LF, indentazione a 4 spazi, niente spazi a fine riga.
- File di sistema in `overlay/`, nomi dei pacchetti in `packages/`, immagini in `assets/`.

### Struttura dei commit

Una modifica logica per commit. Unisci le correzioni al commit che correggono e
aggiorna il ramo con rebase su `main`, senza merge.

### Messaggi di commit

- Prima riga: riassunto breve all'imperativo, al massimo 72 caratteri.
- Riga vuota e poi, se serve, il corpo con cosa e perché.
- Riferimenti alle issue con `Fixes #123`.
- Chiudi con una riga `Signed-off-by:`.

### Autore

I commit devono avere un nome reale o uno pseudonimo stabile e un indirizzo
email valido. La cronologia è permanente.

### Signed-off-by

Usa `git commit -s`. Così dichiari il
[Developer Certificate of Origin](https://developercertificate.org/): hai
scritto la modifica o hai il diritto di inviarla con la licenza del progetto.

## Aspettative di qualità

I contributi di bassa qualità possono essere chiusi. Non inviare codice di cui
non hai i diritti o con licenza incompatibile. Rispondi ai commenti della
revisione: le pull request ferme da un mese possono essere chiuse e riaperte
in seguito.

## Licenza dei contributi

I contributi sono rilasciati con la **licenza BSD a 2 clausole**, come
il resto del progetto.
