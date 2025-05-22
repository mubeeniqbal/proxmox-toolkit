#!/bin/bash
#
# Verify that zfs-import-scan is disabled and masked.
# Check if the watchdog timer is working as expected.

source /usr/local/lib/shell_modes.sh
enable_strict_mode

source /usr/local/lib/assert.sh
assert_root_user

readonly SERVICE_NAME='zfs-import-scan'
readonly SERVICE="${SERVICE_NAME}.service"
readonly WATCHDOG_NAME="${SERVICE_NAME}-watchdog"
readonly WATCHDOG_TIMER="${WATCHDOG_NAME}.timer"

readonly LOG_TAG="${WATCHDOG_NAME}"
source /usr/local/lib/log.sh

# Set traps (see traps.sh)
readonly TRAP_TAG="${WATCHDOG_NAME}"
source /usr/local/lib/traps.sh

trap 'catch_err $LINENO $?' ERR
trap 'on_exit' EXIT INT TERM
# End: Set traps

check_service_is_disabled() {
  assert_unit_exists "${SERVICE}"

  if ! systemctl is-enabled --quiet "${SERVICE}"; then
    log_info "✅ ${SERVICE} is disabled."
  else
    log_error "❌ ${SERVICE} is NOT disabled!"
    exit 1
  fi
}

check_service_is_masked() {
  assert_unit_exists "${SERVICE}"

  if [[ "$(systemctl show -p LoadState --value "${SERVICE}")" == "masked" ]]; then
    log_info "✅ ${SERVICE} is masked."
  else
    log_error "❌ ${SERVICE} is NOT masked!"
    exit 1
  fi
}

# Check if the watchdog timer is enabled AND active.
check_watchdog_timer_status() {
  assert_unit_exists "${WATCHDOG_TIMER}"

  if systemctl is-enabled --quiet "${WATCHDOG_TIMER}"; then
    log_info "✅ ${WATCHDOG_TIMER} is enabled."
  else
    log_error "❌ ${WATCHDOG_TIMER} is NOT enabled!"
    exit 1
  fi

  if systemctl is-active --quiet "${WATCHDOG_TIMER}"; then
    log_info "✅ ${WATCHDOG_TIMER} is active."
  else
    log_error "❌ ${WATCHDOG_TIMER} is NOT active!"
    exit 1
  fi
}

# Check last execution of watchdog timer.
check_last_watchdog_execution() {
  assert_unit_exists "${WATCHDOG_TIMER}"

  log_info "Checking last execution of ${WATCHDOG_TIMER}..."
  
  local last_trigger
  last_trigger="$(systemctl show "${WATCHDOG_TIMER}" -p LastTriggerUSec --value)"
  log_info "📅 Last watchdog trigger time: ${last_trigger:-Unavailable}"
}

print_summary() {
  local service_is_disabled
  service_is_disabled="$(systemctl is-enabled --quiet "${SERVICE}" && echo '❌ No' || echo '✅ Yes')"

  local state service_is_masked
  state="$(systemctl show -p LoadState --value "${SERVICE}")"
  service_is_masked="$([[ "${state}" == "masked" ]] && echo '✅ Yes' || echo '❌ No')"

  local watchdog_timer_is_enabled
  watchdog_timer_is_enabled="$(systemctl is-enabled --quiet "${WATCHDOG_TIMER}" && echo '✅ Yes' || echo '❌ No')"

  local watchdog_timer_is_active
  watchdog_timer_is_active="$(systemctl is-active --quiet "${WATCHDOG_TIMER}" && echo '✅ Yes' || echo '❌ No')"

  echo ''
  echo '📋 REPORT'
  echo '---------------------------------------------'
  echo "Service        : ${SERVICE}"
  echo "  Disabled     : ${service_is_disabled}"
  echo "  Masked       : ${service_is_masked}"
  echo ''
  echo "Watchdog Timer : ${WATCHDOG_TIMER}"
  echo "  Enabled      : ${watchdog_timer_is_enabled}"
  echo "  Active       : ${watchdog_timer_is_active}"
  echo '---------------------------------------------'
  echo ''
}

main() {
  # Perform checks
  log_info "Starting verification process for ${SERVICE} and watchdog..."

  check_service_is_disabled
  check_service_is_masked
  check_watchdog_timer_status
  check_last_watchdog_execution

  print_summary

  log_info '✅ Verification complete. Everything seems to be working correctly.'
}

main "$@"