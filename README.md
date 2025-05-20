# fix-time-sync-systemd
fix those pesky time sync issues due to snapshot etc.

## Installation Steps
1. Copy the script and service to their proper locations:
```bash
sudo cp fix-time-sync-final.sh /usr/local/bin/fix-time-sync.sh
sudo chmod +x /usr/local/bin/fix-time-sync.sh

sudo cp fix-time-sync.service /etc/systemd/system/fix-time-sync.service
```
2. Enable the service (runs on every boot):
```bash
sudo systemctl daemon-reload
sudo systemctl enable fix-time-sync.service
```
3. (Optional) Run it immediately to verify:
```bash
sudo systemctl start fix-time-sync.service
sudo journalctl -u fix-time-sync.service --no-pager
```
