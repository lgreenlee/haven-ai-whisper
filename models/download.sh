#!/bin/bash
# Download whisper large-v3 model in GGML format for whisper.cpp
set -e

MODELS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_NAME="ggml-large-v3"
MODEL_FILE="${MODEL_NAME}.bin"
MODEL_PATH="${MODELS_DIR}/${MODEL_FILE}"

# Hugging Face mirror used by whisper.cpp project
HF_BASE="https://huggingface.co/ggerganov/whisper.cpp/resolve/main"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -f "${MODEL_PATH}" ]; then
    echo -e "${GREEN}Model already exists: ${MODEL_PATH}${NC}"
    exit 0
fi

echo -e "${YELLOW}Downloading ${MODEL_FILE} (~3.1 GB)...${NC}"
curl -L --progress-bar \
    "${HF_BASE}/${MODEL_FILE}" \
    -o "${MODEL_PATH}"

echo -e "${GREEN}Model saved to: ${MODEL_PATH}${NC}"
