# Proxmox Toolkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A collection of hardened shell scripts and modular Bash libraries for managing Proxmox environments with precision and safety. Designed for operators who value fail-fast behavior, clean logs, and maintainable infrastructure code.

## 📂 Structure

- `lib/` — Shared Bash modules (logging, assertions, traps, modes)
- `sbin/` — Executable scripts to control and verify ZFS import behavior
  - `zfs-import-scan-disable.sh` — Disable and watchdog `zfs-import-scan`
  - `zfs-import-scan-enable.sh` — Re-enable default Proxmox ZFS handling
  - `zfs-import-scan-watchdog-verify.sh` — Validate protection is working

## ✅ Features

- Defensive ZFS pool protection for TrueNAS VMs inside Proxmox
- Persistent service masking via systemd override + watchdog timer
- Reusable libraries for assertions, structured logging, and shell behavior
- Consistent trap handling on `ERR`, `EXIT`, `INT`, `TERM`

## 📦 Installation

```shell
make install
```

- Please don't run `install.sh` directly.
- Only use the make targets.
- Run `make help` for more info.

## Requirements

- Proxmox VE (or any system using zfs-import-scan.service)
- Systemd
- Bash 4+

## 🧠 Philosophy

- 🛡 Fail-fast, error-aware
- 📚 Readable and modular
- 🧼 Minimal but opinionated

---

## Maintainer

**Xulémān** (Mubeen Iqbal)

Tech Entrepreneur · Product Enthusiast · Engineering Aficionado

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.