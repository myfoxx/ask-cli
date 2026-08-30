# ASK - Assistente AI Intelligente per Shell

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Bash 4.0+](https://img.shields.io/badge/Bash-4.0+-blue.svg)](https://www.gnu.org/software/bash/)
[![Ollama Richiesto](https://img.shields.io/badge/Richiede-Ollama-purple.svg)](https://ollama.com)

**ask** è un wrapper intelligente per [Ollama](https://ollama.com/) che porta la potenza degli LLM direttamente nel tuo terminale. Seleziona automaticamente il modello migliore per la tua richiesta (coding, ragionamento, chat), gestisce il contesto del sistema operativo e mantiene il tuo workflow efficiente.

## Funzionalità

- **Routing Intelligente**: Rileva l'intento della domanda e sceglie il modello giusto:
  - **Coding/Scripting/Debug/Ragionamento** -> `qwen3.5:latest` (modello medio, gira con `--think=false` per risposte veloci e senza divagazioni)
  - **Domande generiche/veloci** -> `gemma3:1b` (piccolo, quasi istantaneo)
  - Se il modello scelto non è installato, fallback automatico su `gemma3:1b` -> `gemma:2b` -> `qwen3.5:latest` -> `gemma4:e4b`.
- **Modalità Veloce** (`-f` / `--fast`): Forza il modello più piccolo/veloce (`gemma3:1b`) per una risposta istantanea.
- **Contesto Dinamico**: Rileva automaticamente OS e Shell per fornire comandi corretti (funziona su Arch, Debian, Fedora, macOS, ecc.).
- **Contesto Directory** (`-c`): Injecta in modo sicuro la struttura della cartella corrente (usando `eza`/`exa`) nel prompt.
- **Analisi Errori** (`-e`): Modalità speciale per debuggare comandi falliti o analizzare log via pipe.
- **Risposte Concise, Senza Fronzoli**: Il system prompt limita le risposte a ~5 righe, vieta disclaimer/domande di chiusura, e disabilita il "ragionamento" interno del modello: ottieni un comando, non un saggio.
- **Output Formattato**: Usa `glow` (se installato) per renderizzare il markdown con colori e sintassi evidenziata.
- **Sicurezza**: Ti avvisa prima di suggerire comandi realmente distruttivi (`rm -rf`, `dd`, `mkfs`, `DROP TABLE`, ecc.) — senza inventare rischi su comandi innocui in sola lettura.

## Dipendenze

- **Richiesti**:
  - `bash` (4.0+)
  - `ollama` (consigliata 0.20+, per il supporto al flag `--think`; deve essere installato e in esecuzione)
  - **Modelli**: Assicurati di aver scaricato i modelli usati (o modificato lo script):

    ```bash
    ollama pull qwen3.5
    ollama pull gemma3:1b
    ```

- **Opzionali (Consigliati)**:
  - `glow`: Per il rendering markdown.
  - `eza` o `exa`: Per liste file più pulite nel contesto.

## Installazione

1. **Clona la repository**:

   ```bash
   git clone https://github.com/myfoxx/ask-cli.git
   cd ask-cli
   ```

2. **Rendi eseguibile lo script**:

   ```bash
   chmod +x ask
   ```

3. **Installa nel PATH** (consigliato):

   ```bash
   sudo cp ask /usr/local/bin/
   # OPPURE linkalo localmente
   mkdir -p ~/.local/bin
   ln -s "$(pwd)/ask" ~/.local/bin/ask
   ```

## Utilizzo

### Base

```bash
ask "come estraggo un file tar.gz?"
```

### Con Contesto (`-c`)

Utile per domande sui file nella cartella corrente.

```bash
cd mio-progetto
ask -c "spiegami la struttura di questo progetto"
```

### Modalità Errore (`-e`)

Analizza errori in due modi:

1. **Wrapper (Esegui e Controlla)**:

   ```bash
   ask -e make build
   ```

   *Esegue `make build`. Se fallisce, cattura l'errore e lo spiega.*

2. **Pipe (Analizza Output)**:

   ```bash
   cat errore.log | ask -e "analizza questo errore"
   ```

### Forza un Modello (`-m`)

```bash
ask -m qwen3.5:latest "scrivi una poesia su Linux"
```

### Modalità Veloce (`-f` / `--fast`)

Salta il routing e forza il modello più piccolo/veloce per una risposta istantanea:

```bash
ask -f "come elenco i file ordinati per dimensione?"
```

### Flag Avanzati

- **Limitazione Input** (`-l`): Tronca grandi log per evitare overflow di token
  ```bash
  ask -e -l 50 make build  # Max 50 righe di errore
  ```

- **Timeout** (`-t`): Previeni hang su modelli lenti
  ```bash
  ask -t 30 "spiegami kubernetes"  # 30 secondi di timeout
  ```

- **Salva Output** (`-s`): Salva risposte su file
  ```bash
  ask -s note.md "spiegami Docker"
  ask -a -s cronologia.log "spiegami Ansible"  # Append con -a
  ```

- **Cache** (`--cache`): Memorizza risposte per query ripetute
  ```bash
  ask --cache "come installo rust?"  # Istantaneo la seconda volta
  ask --clear-cache  # Svuota cache
  ```

- **Lista Modelli** (`--list-models`): Mostra modelli Ollama disponibili
  ```bash
  ask --list-models
  ```

- **Output Grezzo** (`-R`): Disabilita formattazione glow
  ```bash
  ask -R "domanda" | grep "specifico"
  ```

- **Verbose** (`-v`): Mostra informazioni di debug
  ```bash
  ask -v "domanda"
  ```

## Configurazione

### File di Configurazione (~/.askrc)

Crea `~/.askrc` per personalizzare i default. Vedi `.askrc-example` per le opzioni disponibili:

```bash
# ~/.askrc
VERBOSE=true
MAX_LINES=100
TIMEOUT=120
CACHE_ENABLED=true
export OLLAMA_KEEP_ALIVE=30m   # tiene il modello in VRAM tra una chiamata e l'altra
```

> Evita di impostare `DEFAULT_MODEL` in `~/.askrc` a meno che tu non voglia fissare ogni query a un solo modello — bypassa completamente il routing intelligente (tranne in modalità errore `-e`).

### Alias Consigliati

Aggiungi questi alias al tuo `.bashrc` o `.zshrc` (presenti anche in `alias.txt`):

```bash
alias askcode='ask -m qwen3.5:latest'         # Specialista Coding/Debug
alias askhere='ask -c'                        # Con contesto locale
alias askerr='ask -e'                         # Debugger errori
alias askv='ask -v'                           # Modalità verbose
alias askfast='ask -f'                        # Risposta istantanea (gemma3:1b)
alias askarchive='ask -a -s ~/.ask-history'   # Salva nella cronologia
```

## Documentazione

- **Guida Base**: Vedi [README_IT.md](README_IT.md) (questo file)
- **Utilizzo Avanzato**: Vedi [ADVANCED.md](ADVANCED.md) per casi particolari, suggerimenti di performance e esempi complessi


## Licenza

Distribuito sotto licenza MIT. Vedi il file [LICENSE](LICENSE) per i dettagli.
