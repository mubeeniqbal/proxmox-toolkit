#!/bin/bash
#
# Set traps for consistent error and exit handling.
# Note: Save this file to /usr/local/lib/
#
# Add these lines at the beginning of the files you want to set traps for:
#
# # Set the trap tag used in logging for trap code. Make sure to set it BEFORE
# # sourcing traps.sh.
# readonly TRAP_TAG='<tag_name>'
#
# # Load common trap handlers.
# source /usr/local/lib/traps.sh
# 
# # SET TRAPS
#
# # Traps:
# # - ERR: Catches runtime errors and logs them.
# # - EXIT: Catches script exit and logs the final status.
# # - INT/TERM: Ensures graceful shutdown on interruption or termination.
#
# # Catch runtime errors and log them with the failing line number and exit code.
# trap 'catch_err $LINENO $?' ERR
#
# # Always run this on script exit (success, failure, interrupts/SIGINT,
# termination/SIGTERM) to log final status.
# trap 'on_exit' EXIT INT TERM

source /usr/local/lib/assert.sh
assert_command logger

if [[ -z "${TRAP_TAG:-}" || "${TRAP_TAG// }" == "" ]]; then
  echo "TRAP_TAG must be set and non-blank before sourcing traps.sh" >&2
  exit 1
fi

# Logs and reports the error line and exit code if any command fails.
catch_err() {
  local line=$1
  local code=$2

  echo "[ERROR] ❌ Script failed at line \"${line}\" with exit code ${code}." >&2
  command logger -t "${TRAP_TAG}" "[ERROR] ❌ Script failed at line \"${line}\" with exit code ${code}."
}

# Runs on any script exit — logs success only if no errors occurred.
on_exit() {
  local code="$?"

  if [[ "${code}" -eq 0 ]]; then
    echo '[INFO] Script completed successfully.'
    command logger -t "${TRAP_TAG}" "[INFO] Script completed successfully."
  else
    echo "[INFO] Script exited with exit code ${code}."
    command logger -t "${TRAP_TAG}" "[INFO] Script exited with exit code ${code}."
  fi
}