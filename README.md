# ASK - Intelligent AI Shell Helper

**ask** is a smart Bash wrapper for [Ollama](https://ollama.com/) that brings the power of multiple LLMs directly to your terminal. It automatically selects the best model for your specific query, manages system context, and keeps your shell workflow efficient.

## Features

- **Smart Model Routing**: Automatically detects the intent of your query and routes it to the specialized model:
  - **Coding/Scripting** -> `qwen2.5-coder`
  - **Logic/Reasoning/Debugging** -> `deepseek-r1`
  - **General Questions** -> `llama3.1` (or your preferred generalist)
- **Dynamic Context**: Automatically detects your OS and Shell to provide accurate commands (works on Arch, Debian, Fedora, macOS, etc.).
- **Context Awareness** (`-c`): securely injects the current directory structure (using `eza`/`exa` if available) into the AI's context.
- **Error Analysis** (`-e`): Special mode to debug failed commands or analyze error logs via pipe.
- **Beautiful Output**: Automatically formats output with Markdown syntax highlighting using `glow` (if installed).
- **Safety Guardrails**: Explicitly warns you before suggesting destructive commands (`rm -rf`, `dd`, etc.).

## Dependencies

- **Required**:
  - `bash` (4.0+)
  - `ollama` (must be installed and running)
  - **Models**: You need to pull the models used by the script (or edit the script to use yours):

    ```bash
    ollama pull qwen2.5-coder
    ollama pull deepseek-r1
    ollama pull llama3.1
    ```

- **Optional (Recommended)**:
  - `glow`: For beautiful markdown rendering.
  - `eza` or `exa`: For better file listing in context mode.

## Installation

1. **Clone the repository**:

   ```bash
   git clone https://gitlab.com/yourusername/ask.git
   cd ask
   ```

2. **Make it executable**:

   ```bash
   chmod +x ask
   ```

3. **Install to PATH** (optional but recommended):

   ```bash
   sudo cp ask /usr/local/bin/
   # OR link it locally
   mkdir -p ~/.local/bin
   ln -s "$(pwd)/ask" ~/.local/bin/ask
   ```

## Usage

### Basic Usage

```bash
ask "how do I unzip a tar.gz file?"
```

### Context Mode (`-c`)

Includes the current directory file list in the prompt. Useful for "how do I run this project?" questions.

```bash
cd my-project
ask -c "explain the structure of this project"
```

### Error Mode (`-e`) or `askerr`

Analyze errors in two ways:

1. **Wrapper Mode**:

   ```bash
   ask -e make build
   ```

   *Runs `make build`. If it fails, `ask` captures the error and explains it.*

2. **Pipe Mode**:

   ```bash
   cat /var/log/syslog | ask -e "what is causing the crash?"
   ```

### Force a Model (`-m`)

```bash
ask -m mistral "write a poem about linux"
```

## Configuration (Aliases)

We recommend adding the provided aliases to your `.bashrc` or `.zshrc` for a faster workflow:

```bash
alias askcode='ask -m qwen2.5-coder:latest'   # Coding specialist
alias askhere='ask -c'                        # Context aware
alias askerr='ask -e'                         # Error analysis
```

## License

MIT License. See [LICENSE](LICENSE) file for details.
