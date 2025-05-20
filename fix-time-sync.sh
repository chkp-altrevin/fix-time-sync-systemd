#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/time-sync-basic.log"
log() {
  echo "$(date '+%F %T') - $*" | tee -a "$LOG_FILE"
}

log_warn() {
  echo "$(date '+%F %T') - ⚠ $*" | tee -a "$LOG_FILE"
}

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  log "❌ This script must be run as root."
  exit 1
fi

log "🔄 Checking and enabling systemd-timesyncd..."

# Step 1: Install timesyncd if needed
if ! systemctl list-unit-files | grep -q systemd-timesyncd.service; then
  log "🛠️ Installing systemd-timesyncd..."
  apt-get update
  apt-get install -y systemd-timesyncd
else
  log "✔ systemd-timesyncd is present."
fi

# Step 2: Enable NTP sync
log "🧭 Enabling NTP via timedatectl..."
timedatectl set-ntp true

# Step 3: Enable and restart the service
log "🔄 Restarting systemd-timesyncd..."
systemctl enable systemd-timesyncd
systemctl restart systemd-timesyncd

# Step 4: Use ntpdate as a manual sync method
if ! command -v ntpdate >/dev/null 2>&1; then
  log "🔍 ntpdate not found, installing..."
  apt-get install -y ntpdate
fi

log "⏱ Forcing manual NTP sync via ntpdate..."
ntpdate -u pool.ntp.org

# Step 5: Ensure hwclock exists, fallback and validate /dev/rtc
if ! command -v hwclock >/dev/null 2>&1; then
  log "🔧 hwclock not found, installing util-linux..."
  apt-get install -y util-linux
fi

if [ -e /dev/rtc ] && [ -x /usr/sbin/hwclock ]; then
  log "🕰 Syncing system time to hardware clock..."
  /usr/sbin/hwclock --systohc
else
  log_warn "hwclock not available or RTC device missing. Skipping hardware clock sync."
fi

# Step 6: Final system update after success
log "📦 Performing apt-get update and upgrade..."
apt-get update && apt-get upgrade -y

# Final report
log "📅 Current system time: $(date)"
timedatectl status | tee -a "$LOG_FILE"

log "✅ Basic NTP time sync and update complete."
