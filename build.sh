#!/bin/bash
# Build whisper.cpp with CUDA support (falls back to CPU if CUDA unavailable)
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WHISPER_CPP_DIR="${REPO_DIR}/whisper.cpp"
WHISPER_CPP_REPO="https://github.com/ggerganov/whisper.cpp.git"
BIN_DIR="${REPO_DIR}/bin"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== haven-ai-whisper build ===${NC}"

# Clone or update whisper.cpp
if [ -d "${WHISPER_CPP_DIR}/.git" ]; then
    echo -e "${YELLOW}Updating whisper.cpp...${NC}"
    git -C "${WHISPER_CPP_DIR}" pull
else
    echo -e "${YELLOW}Cloning whisper.cpp...${NC}"
    git clone "${WHISPER_CPP_REPO}" "${WHISPER_CPP_DIR}"
fi

# Detect CUDA
CUDA_ARGS=""
if command -v nvcc &>/dev/null; then
    echo -e "${GREEN}CUDA detected — building with GPU support${NC}"
    CUDA_ARGS="-DGGML_CUDA=ON"
else
    echo -e "${YELLOW}CUDA not found — building CPU-only${NC}"
fi

# Build
echo -e "${YELLOW}Building whisper.cpp...${NC}"
cmake -S "${WHISPER_CPP_DIR}" -B "${WHISPER_CPP_DIR}/build" \
    -DCMAKE_BUILD_TYPE=Release \
    -DWHISPER_BUILD_SERVER=ON \
    ${CUDA_ARGS}

cmake --build "${WHISPER_CPP_DIR}/build" --config Release -j"$(nproc)"

# Copy server binary to bin/
mkdir -p "${BIN_DIR}"
cp "${WHISPER_CPP_DIR}/build/bin/whisper-server" "${BIN_DIR}/whisper-server"
echo -e "${GREEN}Binary installed to: ${BIN_DIR}/whisper-server${NC}"

echo ""
echo -e "${GREEN}Build complete.${NC}"
echo "Next steps:"
echo "  1. Download the model:  ./models/download.sh"
echo "  2. Install the service: sudo ./systemd/install.sh"
