#!/bin/bash
# Install the haven-ai-whisper systemd service
set -e

SERVICE_NAME="haven-ai-whisper"
SERVICE_FILE="${SERVICE_NAME}.service"
SYSTEMD_DIR="/etc/systemd/system"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
BIN="${REPO_DIR}/bin/whisper-server"
MODEL="${REPO_DIR}/models/ggml-large-v3.bin"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Must be run as root: sudo ./install.sh${NC}"
    exit 1
fi

# Pre-flight checks
if [ ! -f "${BIN}" ]; then
    echo -e "${RED}Binary not found: ${BIN}${NC}"
    echo "Run ./build.sh first."
    exit 1
fi

if [ ! -f "${MODEL}" ]; then
    echo -e "${RED}Model not found: ${MODEL}${NC}"
    echo "Run ./models/download.sh first."
    exit 1
fi

echo -e "${GREEN}=== Installing ${SERVICE_NAME} ===${NC}"

# Stop existing service if running
if systemctl is-active --quiet "${SERVICE_NAME}"; then
    echo -e "${YELLOW}Stopping existing service...${NC}"
    systemctl stop "${SERVICE_NAME}"
fi

# Copy service file
cp "${SCRIPT_DIR}/${SERVICE_FILE}" "${SYSTEMD_DIR}/${SERVICE_FILE}"
echo "Service file installed to ${SYSTEMD_DIR}/${SERVICE_FILE}"

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"
systemctl start "${SERVICE_NAME}"

sleep 3
echo ""
echo -e "${GREEN}Installation complete.${NC}"
systemctl status "${SERVICE_NAME}" --no-pager -l || true

echo ""
echo "Useful commands:"
echo "  Status:  sudo systemctl status ${SERVICE_NAME}"
echo "  Logs:    sudo journalctl -u ${SERVICE_NAME} -f"
echo "  Restart: sudo systemctl restart ${SERVICE_NAME}"
echo "  Stop:    sudo systemctl stop ${SERVICE_NAME}"
