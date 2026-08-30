# ASK Advanced Usage Guide

This document covers advanced usage scenarios, edge cases, and best practices for the ASK script.

## Configuration File (~/.askrc)

Create a `~/.askrc` file to customize ASK's behavior. See `.askrc-example` for all available options.

### Example: Conservative Settings
```bash
# ~/.askrc
VERBOSE=true
MAX_LINES=100
TIMEOUT=120
CACHE_ENABLED=true
```

### Example: Always Save History
```bash
# ~/.askrc
SAVE_OUTPUT="${HOME}/.ask-history"
APPEND_OUTPUT=true
```

Keep the model resident in VRAM between calls (recommended on limited-VRAM GPUs):
```bash
# ~/.askrc
export OLLAMA_KEEP_ALIVE=30m
```

Pin every query to one model, bypassing smart routing entirely (except `-e` error mode):
```bash
# ~/.askrc
DEFAULT_MODEL="your-custom-model:latest"
```

## Advanced Flags

### Input Limiting (`-l`)
Prevent huge error logs from overwhelming the LLM:

```bash
# Analyze only first 50 lines of a huge logfile
tail -f system.log | ask -e -l 50 "what's wrong?"

# Limit error output from failed build
ask -e -l 100 make build
```

This prevents:
- Token limit issues with large inputs
- Excessive processing time
- Memory problems with very large files

### Timeout (`-t`)
Prevent hanging on slow models or unresponsive Ollama:

```bash
# 30-second timeout
ask -t 30 "explain kubernetes"

# Quick query with tight timeout
ask -t 10 "what is SSH?"

# Long reasoning task with generous timeout
ask -t 300 -m qwen3.5:latest "prove the collatz conjecture"
```

### Output Saving (`-s`, `-a`)
Save responses for documentation or history:

```bash
# Save response to file
ask -s notes.md "explain Docker"

# Append to existing file
ask -a -s history.log "what is ansible?"

# Combine with context for project documentation
ask -c -s project-summary.md "explain this project structure"

# Timestamp output by piping
ask -s "notes-$(date +%Y%m%d-%H%M%S).md" "explain Kubernetes"
```

### Caching (`--cache`)
Cache responses for repeated queries:

```bash
# First time: queries model, saves to cache
ask --cache "how do I install rust?"

# Second time: returns from cache instantly
ask --cache "how do I install rust?"

# View cached files
ls -la ~/.ask-cache/

# Clear all cache
ask --clear-cache
```

## Input Modes

### 1. Direct Questions
```bash
ask "how do I use grep?"
ask "what is a CI/CD pipeline?"
```

### 2. Wrapper Mode (Error Analysis)
```bash
# Run command and analyze if it fails
ask -e make build
ask -e ./deploy.sh
ask -e npm test
```

The script:
- Runs the command
- If it succeeds: shows output and exits
- If it fails: captures output and explains the error

### 3. Pipe Mode (Log Analysis)
```bash
# Analyze application logs
cat /var/log/nginx/error.log | ask -e "what caused this 503?"

# Analyze system logs
journalctl -u systemd-networkd | ask -e "why did network fail?"

# Debug Docker output
docker build . 2>&1 | ask -e -l 100 "why is build failing?"

# Git diff analysis
git diff HEAD~1 | ask -c "what changed?"
```

## Model Selection

The script automatically selects the best model based on query intent:

### Automatic Routing
```bash
ask "how do I write a Python script?"        # → qwen3.5:latest (code)
ask "debug my nodejs error"                  # → qwen3.5:latest (debug/reasoning)
ask "how do I use Docker?"                   # → qwen3.5:latest (code)
ask "what is Linux?"                         # → gemma3:1b (general fallback)
```

`-f`/`--fast` skips routing entirely and forces `gemma3:1b`:
```bash
ask -f "what is Linux?"
```

### Force Specific Model
```bash
ask -m qwen3.5:latest "prove this theorem"
ask -m gemma3:1b "tell me a quick fact about climate change"
```

Legacy shortcuts still work and map to the models actually installed: `-m coder`, `-m deep`, `-m llama`, `-m mistral`, `-m big` all resolve to `qwen3.5:latest`; `-m fast`, `-m small`, `-m tiny` resolve to `gemma3:1b`.

## Combining Flags

### Complex Example 1: Large Error Log Analysis
```bash
# Limit to 50 lines, timeout after 60s, save analysis
cat huge-error.log | ask -e -l 50 -t 60 -s debug-report.md "what's the root cause?"
```

### Complex Example 2: Project Documentation
```bash
# Include context, cache result, save to file, verbose
ask -c --cache -s project-guide.md -v "explain this codebase"
```

### Complex Example 3: CI/CD Debugging
```bash
# Run failing test, limit output, with reasoning model, save report
ask -e -l 100 -m qwen3.5:latest -s test-failure-analysis.md npm test
```

## Edge Cases and Workarounds

### 1. Special Characters in Questions
Always quote your questions to prevent shell interpretation:

```bash
# WRONG - shell expands $VAR
ask explain the $VAR variable

# RIGHT - quoting protects special chars
ask 'explain the $VAR variable'
ask "what is 'grep' and 'find'?"
```

### 2. Very Long Prompts
If your question or input is extremely long:

```bash
# Save question to file, read it
ask "$(cat question.txt)"

# Or pipe it
cat question.txt | ask -e "analyze this"
```

### 3. Non-ASCII Characters
ASK supports UTF-8 out of the box:

```bash
ask "write hello world in multiple languages: 你好, Привет, مرحبا"
ask "what is the difference between é and e?"
```

### 4. Very Large Log Files
Always use `-l` to truncate:

```bash
# DON'T do this with huge files
cat 10GB-logfile.log | ask -e "what went wrong?"

# DO this instead
tail -n 100 10GB-logfile.log | ask -e -l 100 "what went wrong?"
```

### 5. Output Redirection and Piping
Be careful with output handling:

```bash
# Save to file instead of using >
ask -s output.txt "question"

# Not recommended (can lose colors/formatting)
ask "question" > output.txt

# Pipe formatted output elsewhere
ask "question" | less
ask "question" | grep "specific"
```

### 6. Stdin/Stdout Interaction
```bash
# Reading from stdin in question (may not work as expected)
ask "$(cat file.txt)"  # Better: use full path or pipe mode

# Better: use context mode
cd /path/to/files
ask -c "what is this?"
```

### 7. Timeout Handling
```bash
# If a query times out, it returns an error message
ask -t 5 "complex reasoning task"
# → Error: Request timed out after 5 seconds.

# Increase timeout for heavy computation
ask -t 300 "analyze this code for vulnerabilities"
```

### 8. Cache Considerations
```bash
# Cache is based on full prompt hash
# Different models = different caches
ask --cache -m qwen3.5:latest "hello"
ask --cache -m gemma3:1b "hello"  # Different cache entry

# Queries with context flag have different cache
ask -c "question"  # Different cache than
ask "question"     # Same question without context
```

## Performance Tips

1. **Use -f for quick lookups**
   ```bash
   ask -f "how do I unzip a tar.gz?"  # gemma3:1b, near-instant
   ```

2. **Every query already runs with `--think=false` and `OLLAMA_CONTEXT_LENGTH=4096`**
   `qwen3.5` is a hybrid thinking model — without `--think=false` it leaks its internal
   reasoning into the output, which used to turn a 5-second answer into 60+ seconds.
   Capping context length also keeps VRAM pressure down on 8GB-class GPUs. Both are
   baked into the script; no flag needed.

3. **Set `OLLAMA_KEEP_ALIVE` in `~/.askrc`**
   ```bash
   export OLLAMA_KEEP_ALIVE=30m
   ```
   Keeps the model resident in VRAM between calls instead of reloading it every time.

5. **Use -l for large inputs**
   ```bash
   ask -e -l 50 some-command  # Faster than full output
   ```

6. **Cache frequently asked questions**
   ```bash
   ask --cache "explain oauth2"
   ask --cache "how do I configure nginx?"
   ```

7. **Use appropriate timeouts**
   ```bash
   ask -t 10 "quick question?"     # Fast questions
   ask -t 120 "complex analysis"   # Reasoning tasks
   ```

8. **Disable glow for huge outputs**
   ```bash
   ask -R "very long explanation"  # Skip markdown rendering
   ```

9. **Use error mode instead of manual wrapping**
   ```bash
   # SLOW: outputs first, then queries
   ask "what is the error in: $(some-command 2>&1)"

   # FAST: runs command internally
   ask -e some-command
   ```

## Troubleshooting

### "Ollama server does not seem to be running"
```bash
# Check if ollama is running
pgrep ollama

# Start ollama
ollama serve &

# Or in background
nohup ollama serve > ollama.log 2>&1 &
```

### "Model not found locally"
```bash
# List available models
ollama list

# Download missing model
ollama pull qwen3.5

# Or use --list-models
ask --list-models
```

### Timeout still occurs with large -t value
- Ollama server might be overloaded
- Check `ollama serve` logs
- Try again later or reduce input size

### Cache not working
```bash
# Check cache directory
ls -la ~/.ask-cache/

# Clear cache if corrupted
ask --clear-cache

# Verify cache is enabled
ask -v --cache "test"
```

## Security Considerations

1. **Destructive commands warning**: ASK warns before suggesting `rm -rf`, `dd`, etc.
2. **Input sanitization**: User input is quoted and properly escaped
3. **No eval of user input**: Commands are passed safely
4. **Local-only by default**: No remote API calls (uses local Ollama)

## Tips and Tricks

### Alias suggestions
Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Quick error debugging
alias askerr='ask -e'

# Code/debug specialist
alias askcode='ask -m qwen3.5:latest'

# Instant answer
alias askfast='ask -f'

# With context
alias askhere='ask -c'

# Verbose with caching
alias askv='ask -v --cache'

# Save to archive
alias askarchive='ask -a -s ~/.ask-archive.md'
```

### Quick reference
```bash
# One-liner help
ask --help | head -20

# List cache
ls ~/.ask-cache | wc -l  # How many queries cached

# View recent cached queries
ls -lt ~/.ask-cache | head -5

# Export question history
grep "Request:" ~/.ask-history | cut -d: -f2-
```

### Integration with other tools
```bash
# Use with fzf to select model
MODEL=$(ollama list | awk 'NR>1{print $1}' | fzf)
ask -m "$MODEL" "your question"

# Track query metrics
{
  echo "$(date): $@"
  ask "$@" 2>&1
} | tee -a ~/ask-metrics.log

# Batch analysis
for file in *.log; do
  ask -e -l 50 "What's wrong?" < "$file" > "analysis-$file"
done
```
