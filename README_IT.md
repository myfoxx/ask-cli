# ASK - Assistente AI Intelligente per Shell

**ask** è un wrapper intelligente per [Ollama](https://ollama.com/) che porta la potenza degli LLM direttamente nel tuo terminale. Seleziona automaticamente il modello migliore per la tua richiesta (coding, ragionamento, chat), gestisce il contesto del sistema operativo e mantiene il tuo workflow efficiente.

## Funzionalità

- **Routing Intelligente**: Rileva l'intento della domanda e sceglie il modello specializzato:
  - **Coding/Scripting** -> `qwen2.5-coder`
  - **Logica/Debug** -> `deepseek-r1`
  - **Generale** -> `llama3.1` (o un generalista a scelta)
- **Contesto Dinamico**: Rileva automaticamente OS e Shell per fornire comandi corretti (funziona su Arch, Debian, Fedora, macOS, ecc.).
- **Contesto Directory** (`-c`): Injecta in modo sicuro la struttura della cartella corrente (usando `eza`/`exa`) nel prompt.
- **Analisi Errori** (`-e`): Modalità speciale per debuggare comandi falliti o analizzare log via pipe.
- **Output Formattato**: Usa `glow` (se installato) per renderizzare il markdown con colori e sintassi evidenziata.
- **Sicurezza**: Ti avvisa esplicitamente prima di suggerire comandi distruttivi (`rm -rf`, `dd`, ecc.).

## Dipendenze

- **Richiesti**:
  - `bash` (4.0+)
  - `ollama` (deve essere installato e in esecuzione)
  - **Modelli**: Assicurati di aver scaricato i modelli usati (o modificato lo script):

    ```bash
    ollama pull qwen2.5-coder
    ollama pull deepseek-r1
    ollama pull llama3.1
    ```

- **Opzionali (Consigliati)**:
  - `glow`: Per il rendering markdown.
  - `eza` o `exa`: Per liste file più pulite nel contesto.

## Installazione

1. **Clona la repository**:

   ```bash
   git clone https://gitlab.com/tuo-username/ask.git
   cd ask
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

### Modalità Errore (`-e`) o `askerr`

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

## Alias Consigliati

Per un'esperienza ottimale, aggiungi questi alias al tuo `.bashrc` o `.zshrc` (trovi il file `alias.txt` nella repo):

```bash
alias askcode='ask -m qwen2.5-coder:latest'   # Specialista Coding
alias askhere='ask -c'                        # Con contesto locale
alias askerr='ask -e'                         # Debugger errori
```

## Licenza

Distribuito sotto licenza MIT. Vedi il file [LICENSE](LICENSE) per i dettagli.
