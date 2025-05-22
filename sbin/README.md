# Proxmox ZFS Import Scan Control Scripts

This directory contains administrative scripts for managing and safeguarding ZFS import behavior on Proxmox systems. It provides automation for disabling or re-enabling the `zfs-import-scan.service`, along with a watchdog system to ensure it stays in the desired state.

## 📁 Scripts Overview

| Script                                | Purpose                                                                 |
|---------------------------------------|-------------------------------------------------------------------------|
| `zfs-import-scan-disable.sh`          | Disables `zfs-import-scan.service`, sets systemd override, installs watchdog |
| `zfs-import-scan-enable.sh`           | Re-enables `zfs-import-scan.service` and removes watchdog infrastructure |
| `zfs-import-scan-watchdog-verify.sh`  | Verifies that `zfs-import-scan.service` is disabled, masked, and protected by the watchdog |

## 🔒 Use Cases

These scripts are useful when:
- You're running a TrueNAS VM inside Proxmox and need to prevent host interference with guest-owned ZFS pools.
- You want automated, persistent enforcement of `zfs-import-scan.service` being disabled.

## 🚀 Usage

**Disable and protect:**
```bash
sudo ./zfs-import-scan-disable.sh
```

**Re-enable default behavior:**
```bash
sudo ./zfs-import-scan-enable.sh
```

**Verify status:**
```bash
sudo ./zfs-import-scan-watchdog-verify.sh
```