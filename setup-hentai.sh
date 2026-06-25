#!/usr/bin/env bash
# ==============================================================================
#  Hentai DL Bot — Ubuntu (x86_64/AMD64) Automated Setup
# ==============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}    Starting Automated Setup for Hentai DL Bot        ${NC}"
echo -e "${GREEN}    (Ubuntu x86_64)                                   ${NC}"
echo -e "${GREEN}======================================================${NC}"

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[ERROR] Please run this script with sudo:${NC} sudo bash -c \"\$(curl -fsSL ...)\""
  exit 1
fi

# ==============================================================================
# 1. Update & Essential Tools
# ==============================================================================
echo -e "\n${YELLOW}Step 1/5 — Installing essential tools...${NC}"
apt-get update
apt-get install -y git tar curl gzip gcc python3-dev nano ca-certificates

# ==============================================================================
# 2. Swap Memory Setup (Only if RAM < 4GB)
# ==============================================================================
echo -e "\n${YELLOW}Step 2/5 — Checking system resources...${NC}"
RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
echo -e "Available RAM: ${RAM_MB} MB"
if [[ ${RAM_MB} -ge 4096 ]]; then
    echo -e "${GREEN}[OK] ${RAM_MB} MB RAM detected. No swap needed.${NC}"
elif free | awk '/^Swap:/ {exit !$2}'; then
    echo -e "${GREEN}[OK] Swap is already active.${NC}"
else
    echo "Creating 1GB swap file..."
    dd if=/dev/zero of=/swapfile bs=1M count=1024
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
    echo -e "${GREEN}[OK] Swap memory configured!${NC}"
fi

# ==============================================================================
# 3. Docker Installation
# ==============================================================================
echo -e "\n${YELLOW}Step 3/5 — Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker 2>/dev/null || true
    systemctl start docker 2>/dev/null || service docker start 2>/dev/null || true
    usermod -aG docker "${SUDO_USER:-ubuntu}" 2>/dev/null || true
    echo -e "${GREEN}[OK] Docker installed and started!${NC}"
else
    echo -e "${GREEN}[OK] Docker is already installed.${NC}"
    systemctl start docker 2>/dev/null || service docker start 2>/dev/null || true
fi

# ==============================================================================
# 4. Clone Repository & Setup x86_64 Environment
# ==============================================================================
echo -e "\n${YELLOW}Step 4/5 — Setting up Bot Repository...${NC}"
WORK_DIR="/opt/hentai_dl_bot"

if [[ -d "${WORK_DIR}" ]]; then
    echo "Directory ${WORK_DIR} already exists — pulling latest changes..."
    cd "${WORK_DIR}"
    git stash || true
    git pull origin master || true
else
    git clone https://github.com/VEncod/hentai_dl_bot.git "${WORK_DIR}"
    cd "${WORK_DIR}"
fi

# Create dummy .env if not exists
if [[ ! -f ".env" ]]; then
    cat > .env << 'ENV_EOF'
API_ID=
API_HASH=
BOT_TOKEN=
MONGO_URL=
OWNER_ID=
AUTH_USERS=
ENV_EOF
    echo -e "${GREEN}[INFO] Created template .env file.${NC}"
fi

# Overwrite Dockerfile with x86_64 Optimized version
echo -e "\n${YELLOW}Creating x86_64-optimized Dockerfile...${NC}"
cat > Dockerfile << 'DOCKERFILE_EOF'
FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg \
        wget \
        nodejs \
        npm \
        ca-certificates \
        gcc \
        g++ \
        make \
        python3-dev \
        libffi-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /app
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Download official linux-x64 binary of N_m3u8DL-RE
RUN wget -q https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v0.2.1-beta/N_m3u8DL-RE_Beta_linux-x64_20240828.tar.gz \
    && tar -xzf N_m3u8DL-RE_Beta_linux-x64_20240828.tar.gz \
    && mv N_m3u8DL-RE_Beta_linux-x64/N_m3u8DL-RE /usr/local/bin/ \
    && chmod +x /usr/local/bin/N_m3u8DL-RE \
    && rm -rf N_m3u8DL-RE_Beta_linux-x64*

COPY . .

# Ensure the app uses the x64 binary
RUN mkdir -p /app/binary && \
    ln -sf /usr/local/bin/N_m3u8DL-RE /app/binary/N_m3u8DL-RE

CMD ["python3", "app.py"]
DOCKERFILE_EOF

# ==============================================================================
# 5. Build Docker Image
# ==============================================================================
echo -e "\n${YELLOW}Step 5/5 — Building Docker Image (This will take a few minutes)...${NC}"
docker build --progress=plain -t hentai-bot:latest .

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN}    SETUP COMPLETE! 🎉                                ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "To start your bot, first edit your environment variables:"
echo -e "  ${YELLOW}sudo nano /opt/hentai_dl_bot/.env${NC}"
echo -e "\nThen run the bot using this command:"
echo -e "  ${YELLOW}sudo docker run -d --name hentai_dl_bot --env-file /opt/hentai_dl_bot/.env --restart unless-stopped --memory=768m hentai-bot:latest${NC}"
echo -e "\nTo check logs: ${YELLOW}sudo docker logs hentai_dl_bot${NC}"
