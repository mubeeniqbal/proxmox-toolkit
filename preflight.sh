#!/bin/bash
#
# Preflight validation for Proxmox Toolkit to check
# environment readiness.

set -euo pipefail

main() {
  echo 'Running preflight validation...'

  [[ "$(uname -s)" == "Linux" ]] || {
    echo '[ERROR] ❌ Only Linux is supported.' >&2
    exit 1
  }

  [[ "${EUID}" -eq 0 ]] || {
    echo '[ERROR] ❌ This script must be run as root.' >&2
    exit 1
  }

  pidof systemd &>/dev/null || {
    echo '[ERROR] ❌ Systemd is not running. This setup requires systemd.' >&2
    exit 1
  }

  local cmd
  for cmd in systemctl logger bash; do
    command -v "${cmd}" &>/dev/null || {
      echo "[ERROR] ❌ Required command \"${cmd}\" not found." >&2
      exit 1
    }
  done

  echo '✅ All preflight checks passed.'
}

main "$@"