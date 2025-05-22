#!/bin/bash
#
# Shared logging functions for consistent syslog and console output.
# Note: Save this file to /usr/local/lib/
#
# Add these lines at the beginning of any script that needs logging:
#
# # Set the log tag used in all log statements. Must be set BEFORE
# # sourcing log.sh.
# readonly LOG_TAG='<tag_name>'
#
# # Load shared logging function.
# source /usr/local/lib/log.sh
#
# Usage:
#   log_info "Starting service..."
#   log_warn "⚠️ Something unusual happened."
#   log_error "❌ Fatal error occurred."
#
# All logs are printed to stdout and syslog under the specified LOG_TAG.
# If LOG_TAG is unset or blank, the script will exit with an error.

source /usr/local/lib/assert.sh
assert_command logger

if [[ -z "${LOG_TAG:-}" || "${LOG_TAG// }" == "" ]]; then
  echo "LOG_TAG must be set and non-blank before sourcing log.sh" >&2
  exit 1
fi

# Logs an informational message.
log_info() {
  echo "[INFO] $*"
  command logger -t "${LOG_TAG}" "[INFO] $*"
}

# Logs a warning message.
log_warn() {
  echo "[WARN] $*" >&2
  command logger -t "${LOG_TAG}" "[WARN] $*"
}

# Logs an error message.
log_error() {
  echo "[ERROR] $*" >&2
  command logger -t "${LOG_TAG}" "[ERROR] $*"
}