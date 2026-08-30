# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2.0] - 2026-08-31

### Fixed
- **Model Routing**: Routing and fallback chain pointed at models that were never actually
  pulled (`qwen2.5-coder`, `deepseek-r1`, `llama3.1`, `mistral`), causing every query to
  silently fall back to whatever generic model happened to be installed. Routing and
  fallback chain now target the models actually shipped/tested with (`qwen3.5:latest`,
  `gemma3:1b`, `gemma:2b`, `gemma4:e4b`), ordered smallest/fastest first.
- **Response Latency**: `qwen3.5` is a hybrid thinking model; without disabling thinking
  mode it leaked internal `<think>` reasoning into the output, turning what should be a
  2-7 second answer into 21-67 seconds. Every `ollama run` call now passes `--think=false`.
- **`-m coder`/`-m deep`/`-m llama`/`-m mistral` shortcuts**: previously resolved to
  uninstalled models; now map to `qwen3.5:latest`.

### Added
- **`-f` / `--fast` flag**: forces `gemma3:1b` for a near-instant answer.
- **`-m fast`/`-m small`/`-m tiny`** shortcuts for `gemma3:1b`.
- **`OLLAMA_CONTEXT_LENGTH=4096` cap** on every model call to reduce VRAM pressure on
  8GB-class GPUs when using `-c` (directory context) or large piped/`-e` input.

### Changed
- **System Prompt**: rewritten to cap answers at ~5 lines, forbid disclaimers and
  closing questions ("anything else?"), and stop inventing danger warnings on harmless
  read-only commands. Role line now keys off the actually-installed model
  (`qwen*` vs `gemma*`) instead of dead branches for models that were never installed.
- **Recommended `~/.askrc`**: `OLLAMA_KEEP_ALIVE=30m` replaces a hardcoded `DEFAULT_MODEL`
  override, so the model stays resident in VRAM between calls without bypassing routing.

## [3.1.0] - 2025-01-10

### Added
- **Input Limiting** (`-l LINES`): Truncate large logs to prevent token overflow
- **Explicit Timeout** (`-t SECONDS`): Prevent hanging on slow models
- **Output Management** (`-s FILE`, `-a`): Save and append responses to files
- **Simple Caching** (`--cache`, `--clear-cache`): Cache responses for repeated queries
- **Config File** (`~/.askrc`): Customize defaults and settings
- **List Models** (`--list-models`): Display available Ollama models
- **Color Output**: Enhanced error visibility with colored fallback messages
- **Test Suite** (test.bats): Automated tests with Bats framework
- **Advanced Documentation** (ADVANCED.md): Edge cases, performance tips, troubleshooting
- **Long Flag Support**: `--help`, `--cache`, `--clear-cache`, `--list-models`

### Changed
- **Keyword Routing**: Cleaned up model selection regex (English-only, more consistent)
- **Extended Keyword Patterns**: Added more keywords for better model routing
- **Help System**: Full documentation with `--help` flag and examples
- **Error Messaging**: More detailed verbose output when using `-v`

### Improved
- Code documentation with detailed comments
- Fallback chain visibility (now with colors)
- Error handling robustness

## [3.0.0] - 2025-01-01

### Initial Release
- Smart model routing (qwen2.5-coder, deepseek-r1, llama3.1)
- Error mode with wrapper and pipe support
- Context mode for directory structure injection
- Dynamic OS/Shell detection
- Safety warnings for destructive commands
- Glow markdown formatting support
- Ollama model fallback chain
