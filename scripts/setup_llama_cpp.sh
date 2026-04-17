#!/bin/bash

# Script to setup llama.cpp for OrionHealth Android build
# This script clones llama.cpp and prepares the necessary files.

LLAMA_CPP_DIR="android/app/src/main/cpp/llama.cpp"

if [ ! -d "$LLAMA_CPP_DIR" ]; then
    echo "Cloning llama.cpp..."
    git clone https://github.com/ggerganov/llama.cpp.git "$LLAMA_CPP_DIR"
else
    echo "llama.cpp already exists, updating..."
    cd "$LLAMA_CPP_DIR" && git pull && cd -
fi

echo "llama.cpp setup complete."
echo "Note: The model file should be placed in assets/models/gemma-4-E2B-it-uncensored-Q4_K_M.gguf"
