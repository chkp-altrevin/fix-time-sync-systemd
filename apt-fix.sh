#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/apt-cleanup.log"
log() {
  echo "$(date '+%F %T') - $*" | tee -a "$LOG_FILE"
}

# Must run as root
if [[ $EUID -ne 0 ]]; then
  log "❌ Must be run as root. Exiting."
  exit 1
fi

log "🧹 Cleaning up stale apt/dpkg locks..."

# Step 1: Ensure killall is available
if ! command -v killall &>/dev/null; then
  log "🛠️ killall not found. Installing..."
  apt-get update
  apt-get install -y psmisc
else
  log "✔ killall is available."
fi

# Step 2: Kill any background apt/dpkg processes safely
killall -q apt apt-get dpkg || true

# Step 3: Remove lock files
rm -f /var/lib/apt/lists/lock
rm -f /var/cache/apt/archives/lock
rm -f /var/lib/dpkg/lock*
rm -f /var/lib/dpkg/lock-frontend

# Step 4: Reconfigure dpkg
log "🔧 Reconfiguring dpkg..."
dpkg --configure -a || log "⚠️ dpkg reconfiguration failed but continuing."

# Step 5: Clean apt cache
log "🧼 Cleaning apt cache..."
apt-get clean
apt-get autoclean

# Step 6: Update and fix broken packages
log "🔄 Running apt-get update and fixing broken packages..."
apt-get update
apt-get install -f -y

log "✅ apt cleanup and recovery completed."
