# To Install on Any Ubuntu System:

```bash
sudo dpkg -i fix-time-sync_1.0.deb
sudo systemctl daemon-reload
sudo systemctl enable fix-time-sync.service
sudo systemctl start fix-time-sync.service
```

This will:

- Install the script to /usr/local/bin/fix-time-sync.sh
- Register and enable the systemd service to auto-run at boot
- Sync time, fix drift, and log everything
