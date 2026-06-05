#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building boilerplate-cli-ui-crystal..."

# Compile Crystal binary
/home/jarancibia/ai/system/crystal-1.20.2-1/bin/crystal build src/main.cr -o boilerplate-cli-ui-crystal --release

echo "Build complete: ./boilerplate-cli-ui-crystal"
echo "Binary size: $(du -h boilerplate-cli-ui-crystal | cut -f1)"