# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
