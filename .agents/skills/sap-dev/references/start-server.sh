#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# Detect OS to select correct binary
OS="$(uname -s)"
ARCH="$(uname -m)"

BINARY="../bin/sap-bridge"
if [ "$OS" = "Darwin" ]; then
    if [ "$ARCH" = "arm64" ]; then
        BINARY="../bin/sap-bridge-darwin-arm64"
    else
        BINARY="../bin/sap-bridge-darwin-amd64"
    fi
fi

if [ -f "$BINARY" ]; then
    chmod +x "$BINARY"
    echo "Starting SAP-Bridge HTTP/SSE Daemon on port 58454..."
    "$BINARY" -port 58454
else
    echo "Error: Binary not found at $BINARY"
    exit 1
fi
