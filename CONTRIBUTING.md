# Contributing to ASK

Thank you for interest in contributing to ASK! This document provides guidelines and instructions.

## Code of Conduct

- Be respectful and constructive
- Report bugs clearly with reproduction steps
- Propose features with use cases
- Test your changes before submitting

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork**:

   ```bash
   git clone https://github.com/YOUR-USERNAME/ask-cli.git
   cd ask-cli
   ```

3. **Create a branch** for your feature:

   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development

### Prerequisites

- `bash` 4.0+
- `ollama` running with at least one model
- `bats` for testing (optional but recommended)

### Running Tests

```bash
# Install bats first
# macOS: brew install bats-core
# Linux: apt install bats-core (or equivalent)

bats test.bats
```

### Code Style

- Use 4-space indentation
- Add comments for non-obvious logic
- Quote variables: `"$VAR"` not `$VAR`
- Use `local` for function variables
- Keep functions focused and small

### Testing Your Changes

```bash
# Test basic functionality
./ask "hello"

# Test with your changes
./ask -v "test query"

# Test error mode
./ask -e ls /nonexistent

# Run test suite
bats test.bats
```

## Submitting Changes

1. **Make your changes** and test thoroughly
2. **Update CHANGELOG.md** with your additions
3. **Commit with clear messages**:

   ```bash
   git commit -m "Add feature: description"
   # or
   git commit -m "Fix: description"
   ```

4. **Push to your fork**:

   ```bash
   git push origin feature/your-feature-name
   ```

5.- **Use the Templates**: We have issue and PR templates for a reason. Please use them.

- **Run Tests**: If you add a new feature, add a test case in `test.bats`.

## Bug Reports

When reporting bugs, include:

- ASK version: `git log -1 --pretty=format:"%H"`
- OS and shell: `uname -a` and `echo $SHELL`
- Ollama models available: `ollama list`
- Exact command that failed
- Full error output

## Feature Requests

For new features:

- Describe the use case clearly
- Show example usage
- Explain how it improves ASK
- Consider performance impact

## Documentation

- Update README.md (English) and README_IT.md (Italian) for user-facing changes

- Update ADVANCED.md for edge cases and complex usage
- Keep examples in sync across all documentation

## Release Process

For maintainers releasing new versions:

1. **Update version in files** (if any version references)
2. **Update CHANGELOG.md** with all changes
3. **Create a git tag**:

   ```bash
   git tag -a v3.1.0 -m "Release version 3.1.0"
   git push origin v3.1.0
   ```

4. **Create GitHub Release** with:
   - Version number
   - Changelog summary
   - Installation instructions
   - Known issues/limitations

## Questions?

Open an issue on GitHub with the "question" label, or check:

- [README.md](README.md) - Basic usage
- [ADVANCED.md](ADVANCED.md) - Complex scenarios

## License

By contributing, you agree your changes are licensed under MIT License.
