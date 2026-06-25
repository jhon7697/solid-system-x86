# 🐧 Ubuntu x86_64 Setup Scripts for Anime Bots

One-command setup scripts for running anime download bots on **Ubuntu x86_64/AMD64** servers.

---

## 📥 Quick Download & Run

### 1. AniwatchTvdl Bot
```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/jhon7697/solid-system-x86/main/Aniwatchtvdl.sh)"
```

### 2. Hentai DL Bot
```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/jhon7697/solid-system-x86/main/setup-hentai.sh)"
```

### 3. Animedekho Bot
```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/jhon7697/solid-system-x86/main/setup-animedekho.sh)"
```

---

## ⚙️ Requirements

- **OS:** Ubuntu 20.04+ (or any Debian-based distro)
- **Architecture:** x86_64 / AMD64
- **Privileges:** Root or sudo access
- **RAM:** Minimum 1GB (swap will be auto-configured)
- **Disk:** At least 5GB free space

---

## 🚀 After Installation

### Configure Environment Variables

Each bot creates a `.env` file. Edit it with your credentials:

```bash
# AniwatchTvdl
sudo nano /opt/AniwatchTvdl/.env

# Hentai DL Bot
sudo nano /opt/hentai_dl_bot/.env

# Animedekho Bot
sudo nano /opt/animedekho-bot/.env
```

**Required variables:**
- `API_ID` & `API_HASH` → Get from [my.telegram.org](https://my.telegram.org)
- `BOT_TOKEN` → Get from [@BotFather](https://t.me/BotFather) on Telegram
- `MONGO_URL` / `MONGO_URI` → [MongoDB Atlas](https://www.mongodb.com/atlas) (free tier works)
- `OWNER_ID` → Your Telegram numeric user ID

---

## 📋 Docker Commands

### Start Bot
```bash
# AniwatchTvdl
sudo docker run -d --name aniwatchtv \ --env-file /opt/AniwatchTvdl/.env \ --restart unless-stopped \ --memory=768m \ aniwatchtv:latest

# Hentai DL Bot
sudo docker run -d --name hentai_dl_bot \
  --env-file /opt/hentai_dl_bot/.env \
  --restart unless-stopped \
  --memory=768m \
  hentai-bot:latest

# Animedekho Bot
sudo docker run -d --name animedekho_bot \
  --env-file /opt/animedekho-bot/.env \
  --restart unless-stopped \
  --memory=768m \
  animedekho:latest
```

### View Logs
```bash
# AniwatchTvdl
sudo docker logs -f aniwatchtv

# Hentai DL Bot
sudo docker logs -f hentai_dl_bot

# Animedekho Bot
sudo docker logs -f animedekho_bot
```

### Restart Bot
```bash
# AniwatchTvdl
sudo docker restart aniwatchtv

# Hentai DL Bot
sudo docker restart hentai_dl_bot

# Animedekho Bot
sudo docker restart animedekho_bot
```

### Stop Bot
```bash
# AniwatchTvdl
sudo docker stop aniwatchtv

# Hentai DL Bot
sudo docker stop hentai_dl_bot

# Animedekho Bot
sudo docker stop animedekho_bot
```

### Remove Bot (Container + Image)
```bash
# AniwatchTvdl
sudo docker stop aniwatchtv
sudo docker rm aniwatchtv
sudo docker rmi aniwatchtv:latest

# Hentai DL Bot
sudo docker stop hentai_dl_bot
sudo docker rm hentai_dl_bot
sudo docker rmi hentai-bot:latest

# Animedekho Bot
sudo docker stop animedekho_bot
sudo docker rm animedekho_bot
sudo docker rmi animedekho:latest
```

### Full Cleanup (All containers, images, volumes)
```bash
sudo docker system prune -af
```

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| Docker not found | Script auto-installs Docker. If failed: `curl -fsSL https://get.docker.com \| sh` |
| Build fails due to RAM | 1GB swap is auto-created. For more: `sudo fallocate -l 2G /swapfile` |
| Permission denied | Make sure you're running with `sudo` |
| .env not configured | Edit the `.env` file before starting the container |

---

## 📁 File Locations

| Bot | Install Path | Dockerfile |
|-----|-------------|------------|
| AniwatchTvdl | `/opt/AniwatchTvdl` | Custom x86_64 optimized |
| Hentai DL Bot | `/opt/hentai_dl_bot` | Custom x86_64 optimized |
| Animedekho Bot | `/opt/animedekho-bot` | Custom x86_64 optimized |

---

## 📝 Notes

- Scripts are tested on **Ubuntu 22.04 LTS x86_64**
- ARM64/Amazon Linux version available at [Alaxroy121/solid-system](https://github.com/Alaxroy121/solid-system)
- All bots run inside Docker containers for isolation
- Auto-restart is enabled — bots will restart after server reboot

---

## 🦞 Credits

- Original ARM64 scripts by [Alaxroy121](https://github.com/Alaxroy121)
- x86_64/Ubuntu adaptations by [jhon7697](https://github.com/jhon7697)
