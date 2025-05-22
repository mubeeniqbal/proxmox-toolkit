#!/bin/bash
#
# Disables zfs-import-scan.service to prevent Proxmox from auto-importing ZFS
# pools owned by other systems (e.g., TrueNAS VM).
# Also installs a systemd timer watchdog to keep the service permanently
# disabled.

source /usr/local/lib/shell_modes.sh
enable_strict_mode

source /usr/local/lib/assert.sh
assert_root_user

readonly SERVICE_DIR='/lib/systemd/system'
readonly SYSTEMD_DIR='/etc/systemd/system'
readonly SBIN_DIR='/usr/local/sbin'

assert_dir "${SERVICE_DIR}"
assert_dir "${SYSTEMD_DIR}"
assert_dir "${SBIN_DIR}"

readonly SERVICE_NAME='zfs-import-scan'
readonly SERVICE="${SERVICE_NAME}.service"

readonly OVERRIDE_DIR="${SYSTEMD_DIR}/${SERVICE}.d"
readonly OVERRIDE_FILE_PATH="${OVERRIDE_DIR}/block-start-attempts.conf"

readonly WATCHDOG_NAME="${SERVICE_NAME}-watchdog"
readonly WATCHDOG_SCRIPT_PATH="${SBIN_DIR}/${WATCHDOG_NAME}.sh"
readonly WATCHDOG_SERVICE="${WATCHDOG_NAME}.service"
readonly WATCHDOG_SERVICE_PATH="${SYSTEMD_DIR}/${WATCHDOG_SERVICE}"
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

create_systemd_override() {
  log_info "Creating systemd override at ${OVERRIDE_FILE_PATH} to block ${SERVICE} start attempts..."

  mkdir -p "${OVERRIDE_DIR}"
  cat << EOF > "${OVERRIDE_FILE_PATH}"
# This override blocks any attempts to start ${SERVICE}.

[Service]
ExecStartPre=/bin/sh -c 'echo "⚠️ ALERT: ${SERVICE} attempted to start!" | systemd-cat -t "${WATCHDOG_NAME}"'
ExecStart=/bin/false
EOF
}

disable_and_mask_service() {
  log_info "Disabling and masking ${SERVICE}..."
  
  if systemctl list-unit-files "${SERVICE}" &>/dev/null; then
    systemctl disable --now "${SERVICE}"
    systemctl mask --now "${SERVICE}"
  else
    log_warn "⚠️ ${SERVICE} not found. Skipping disable/mask."
  fi
}

install_watchdog_script() {
  log_info "Installing watchdog script at ${WATCHDOG_SCRIPT_PATH} ..."

  cat << EOF > "${WATCHDOG_SCRIPT_PATH}"
#!/bin/bash
#
# Watchdog script for ${SERVICE}
#
# This script checks if the ${SERVICE} has been re-enabled.
# If so, it immediately disables and masks it again to prevent Proxmox from
# automatically importing ZFS pools (e.g., those owned by TrueNAS VM).
# Intended to be run periodically by a systemd timer as a safeguard.
#
# Logs actions to syslog under the "${WATCHDOG_NAME}" tag.

source /usr/local/lib/shell_modes.sh
enable_strict_mode

readonly LOG_TAG='${WATCHDOG_NAME}'
source /usr/local/lib/log.sh

readonly SERVICE='${SERVICE}'

# Check if ${SERVICE} is enabled. If so, disable it.
if systemctl is-enabled --quiet "\${SERVICE}"; then
  log_warn "⚠️ Detected \${SERVICE} is enabled. Disabling again..."
  systemctl disable --now "\${SERVICE}"
  log_info "\${SERVICE} has been disabled."
else
  log_info "\${SERVICE} is already disabled. Nothing to do."
fi

# Check if ${SERVICE} is unmasked. If so, mask it.
if [[ "\$(systemctl show -p LoadState --value "\${SERVICE}")" != "masked" ]]; then
  log_warn "⚠️ Detected \${SERVICE} is unmasked. Masking again..."
  systemctl mask --now "\${SERVICE}"
  log_info "\${SERVICE} has been masked."
else
  log_info "\${SERVICE} is already masked. Nothing to do."
fi
EOF
  
  # For good measure: Check for syntax errors in the script created using heredoc.
  bash -n "${WATCHDOG_SCRIPT_PATH}" || {
    log_error "❌ ${WATCHDOG_SCRIPT_PATH} script has syntax errors."
    exit 1
  }

  chmod 755 "${WATCHDOG_SCRIPT_PATH}"
}

install_watchdog_units() {
  log_info "Installing systemd timer at ${WATCHDOG_TIMER_PATH} for watchdog..."

  cat << EOF > "${WATCHDOG_TIMER_PATH}"
# This timer triggers ${WATCHDOG_SERVICE} once 5 minutes after boot
# and every 24 hours thereafter. It ensures ${SERVICE} remains
# disabled and masked.

[Unit]
Description=Run watchdog 5 minutes after boot and every 24 hours thereafter to keep ${SERVICE} disabled

[Timer]

# Execute job if it missed a run due to machine being off.
Persistent=true

# Run 5 minutes after boot for the first time.
OnBootSec=5min

# Run every 24 hours thereafter.
OnUnitActiveSec=1d


[Install]
WantedBy=timers.target
EOF

  log_info "Installing systemd service at ${WATCHDOG_SERVICE_PATH} for watchdog..."

  cat << EOF > "${WATCHDOG_SERVICE_PATH}"
# This service runs the watchdog script to disable and mask ${SERVICE}.
# It's triggered by ${WATCHDOG_TIMER} and runs only once per execution.

[Unit]
Description=Watchdog service to keep ${SERVICE} disabled
ConditionPathExists=${SERVICE_DIR}/${SERVICE}
After=network.target

[Service]
Type=oneshot
ExecStart=${WATCHDOG_SCRIPT_PATH}
EOF

  # Calling daemon-reload here to ensure enabling timer doesn't fail later.
  systemctl daemon-reload

  # Enable and start the timer (this doesn't run the service immediately).
  systemctl enable --now "${WATCHDOG_TIMER}"

  # Run the watchdog service once immediately.
  systemctl start "${WATCHDOG_SERVICE}"
}

reload_systemd() {
  log_info 'Reloading systemd daemon...'
  systemctl daemon-reload
}

main() {
  create_systemd_override
  disable_and_mask_service
  install_watchdog_script
  install_watchdog_units
  reload_systemd

  log_info "✅ ${SERVICE} has been disabled and watchdog protection is now installed and active."
}

main "$@"