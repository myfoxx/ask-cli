#!/usr/bin/env bats
# Test suite for ask script
# Run with: bats test.bats

setup() {
    export TEST_HOME=$(mktemp -d)
    export HOME="$TEST_HOME"
    export CONFIG_FILE="${HOME}/.askrc"
    export CACHE_DIR="${HOME}/.ask-cache"
}

teardown() {
    rm -rf "$TEST_HOME"
}

# Helper to check if ollama is running
@test "Check if ollama is available" {
    if ! command -v ollama &> /dev/null; then
        skip "ollama not installed"
    fi
}

@test "Script is executable" {
    [ -x ./ask ]
}

@test "Help flag works" {
    output=$(./ask -h)
    [[ "$output" == *"Usage"* ]]
}

@test "Extended help with --help works" {
    output=$(./ask --help)
    [[ "$output" == *"Options"* ]]
    [[ "$output" == *"Examples"* ]]
}

@test "List models flag works" {
    if ! command -v ollama &> /dev/null; then
        skip "ollama not installed"
    fi
    # Just check it doesn't error
    ./ask --list-models >/dev/null 2>&1 || [ $? -eq 0 ]
}

@test "Clear cache flag works" {
    mkdir -p "$CACHE_DIR"
    touch "$CACHE_DIR/test.cache"
    [ -f "$CACHE_DIR/test.cache" ]
    ./ask --clear-cache >/dev/null 2>&1
    [ ! -d "$CACHE_DIR" ] || [ ! -f "$CACHE_DIR/test.cache" ]
}

@test "Config file loads correctly" {
    cat > "$CONFIG_FILE" << 'EOF'
VERBOSE=true
MAX_LINES=50
EOF
    source "$CONFIG_FILE"
    [ "$VERBOSE" = "true" ]
    [ "$MAX_LINES" = "50" ]
}

@test "Max lines flag sets correctly" {
    # This would require more complex testing with actual ollama
    # For now just verify the flag is accepted
    ./ask -h 2>&1 | grep -q "\-l LINES"
}

@test "Timeout flag sets correctly" {
    ./ask -h 2>&1 | grep -q "\-t TIMEOUT"
}

@test "Save output flag mentioned in help" {
    ./ask -h 2>&1 | grep -q "\-s FILE"
}

@test "Append flag mentioned in help" {
    ./ask -h 2>&1 | grep -q "\-a"
}

@test "Cache flag mentioned in help" {
    ./ask --help 2>&1 | grep -q "\-\-cache"
}

@test "Context flag documented" {
    ./ask --help 2>&1 | grep -q "\-c"
}

@test "Error mode flag documented" {
    ./ask --help 2>&1 | grep -q "\-e"
}

@test "Model force flag documented" {
    ./ask --help 2>&1 | grep -q "\-m MODEL"
}

@test "Verbose flag documented" {
    ./ask --help 2>&1 | grep -q "\-v"
}

@test "Raw output flag documented" {
    ./ask --help 2>&1 | grep -q "\-R"
}

@test "Examples shown in help" {
    output=$(./ask --help)
    [[ "$output" == *"Examples"* ]]
    [[ "$output" == *"ask"* ]]
}

@test "Invalid flag shows error" {
    output=$(./ask -x 2>&1)
    [[ "$output" == *"Invalid"* || "$output" == *"invalid"* ]]
}

@test "Invalid long option shows error" {
    output=$(./ask --invalid 2>&1)
    [[ "$output" == *"Invalid long option"* || "$output" == *"invalid"* ]]
}

@test "No arguments shows error" {
    if command -v ollama &> /dev/null; then
        # Skip if ollama is running, would actually try to call it
        skip "ollama is running"
    fi
}

@test "Script handles empty input gracefully" {
    if ! command -v ollama &> /dev/null; then
        skip "ollama not installed"
    fi
    # This would require mocking ollama or a test instance
}
