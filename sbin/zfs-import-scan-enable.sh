#!/bin/bash
#
# Re-enables zfs-import-scan.service and restores default Proxmox behavior.
# Also removes the systemd watchdog script, service, and timer.

source /usr/local/lib/shell_modes.sh
enable_strict_mode

source /usr/local/lib/assert.sh
assert_root_user

readonly SYSTEMD_DIR='/etc/systemd/system'
readonly SBIN_DIR='/usr/local/sbin'

assert_dir "${SYSTEMD_DIR}"
assert_dir "${SBIN_DIR}"

readonly SERVICE_NAME='zfs-import-scan'
readonly SERVICE="${SERVICE_NAME}.service"

readonly OVERRIDE_DIR="${SYSTEMD_DIR}/${SERVICE}.d"

readonly WATCHDOG_NAME="${SERVICE_NAME}-watchdog"
readonly WATCHDOG_SCRIPT="${SBIN_DIR}/${WATCHDOG_NAME}.sh"
readonly WATCHDOG_SERVICE_PATH="${SYSTEMD_DIR}/${WATCHDOG_NAME}.service"
readonly WATCHDOG_TIMER="${WATCHDOG_NAME}.timer"
readonly WATCHDOG_TIMER_PATH="${SYSTEMD_DIR}/${WATCHDOG_TIMER}"

readonly LOG_TAG="${WATCHDOG_NAME}"
source /usr/local/lib/log.sh

# Set traps (see traps.sh)
readonly TRAP_TAG="${WATCHDOG_NAME}"

source /usr/local/lib/traps.sh

trap 'catch_err $LINENO $?' ERR
trap 'on_exit' EXIT INT TERM
# End: Set traps

remove_watchdog_script_and_units() {
  log_info "Disabling ${WATCHDOG_TIMER} ..."

  # Only attempt disable if the timer unit exists and is enabled.
  if systemctl list-unit-files "${WATCHDOG_TIMER}" &>/dev/null; then
    if systemctl is-enabled --quiet "${WATCHDOG_TIMER}"; then
      systemctl disable --now "${WATCHDOG_TIMER}"
    else
      log_info "${WATCHDOG_TIMER} is found but not enabled. Skipping disable."
    fi
  else
    log_info "${WATCHDOG_TIMER_PATH} is not found. Skipping disable."
  fi

  log_info "Removing watchdog script at ${WATCHDOG_SCRIPT} and unit files at ${WATCHDOG_SERVICE_PATH} and ${WATCHDOG_TIMER_PATH} ..."
  rm -f "${WATCHDOG_SCRIPT}" "${WATCHDOG_SERVICE_PATH}" "${WATCHDOG_TIMER_PATH}"
}

remove_systemd_override() {
  log_info "Removing systemd override directory at ${OVERRIDE_DIR} for ${SERVICE}..."

  if [[ -d "${OVERRIDE_DIR}" ]]; then
    rm -rf "${OVERRIDE_DIR}"
  else
    log_info "Systemd override directory at ${OVERRIDE_DIR} not found. Skipping."
  fi
}

reload_systemd() {
  log_info 'Reloading systemd daemon...'
  systemctl daemon-reload
}

unmask_and_enable_service() {
  log_info "Unmasking and enabling ${SERVICE}..."

  if systemctl list-unit-files "${SERVICE}" &>/dev/null; then
    systemctl unmask "${SERVICE}"
    systemctl enable --now "${SERVICE}"
  else
    log_warn "⚠️ ${SERVICE} not found. Skipping unmask/enable."
  fi
}

main() {
  remove_watchdog_script_and_units
  remove_systemd_override
  reload_systemd
  unmask_and_enable_service

  log_info "✅ ${SERVICE} has been enabled and watchdog protection has been deactivated and uninstalled."
}

main "$@"