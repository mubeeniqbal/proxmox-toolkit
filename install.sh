#!/bin/bash
#
# Bootstrap installer for Proxmox Toolkit.

set -euo pipefail

readonly LIB_DIR='/usr/local/lib'
readonly SBIN_DIR='/usr/local/sbin'

main() {
  echo 'Checking for the existence of required directories...'

  local dir
  for dir in "${LIB_DIR}" "${SBIN_DIR}"; do
    [[ -d "${dir}" ]] || {
      echo "[ERROR] ❌ Directory \"${dir}\" does not exist." >&2
      exit 1
    }
  done

  echo '📦 Installing Proxmox Toolkit...'

  echo "Copying scripts to ${LIB_DIR} ..."
  chmod 644 lib/*.sh
  chown root:root lib/*.sh
  cp lib/*.sh "${LIB_DIR}/"

  echo "Copying scripts to ${SBIN_DIR} ..."
  chmod 755 sbin/*.sh
  chown root:root sbin/*.sh
  cp sbin/*.sh "${SBIN_DIR}/"

  echo '✅ Installation complete.'
}

main "$@"