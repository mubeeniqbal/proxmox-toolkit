# Makefile for Proxmox Toolkit.

SHELL := /bin/bash
.DEFAULT_GOAL := help

.PHONY: help verify install reinstall reset clean uninstall

# Show usage help.
help:
	@echo ''
	@echo 'Proxmox Toolkit — Make Targets'
	@echo '---------------------------------------'
	@echo 'make verify      # Run environment checks (must be root)'
	@echo 'make install     # Copy scripts to /usr/local/{lib,sbin}'
	@echo 'make reinstall   # Remove all scripts and install again'
	@echo 'make reset       # Revert system to default state'
	@echo 'make clean       # Remove all scripts'
	@echo 'make uninstall   # Same as clean'
	@echo ''

verify:
	@bash preflight.sh

install: verify
	@bash install.sh

reinstall: uninstall install

reset:
	@echo 'Reverting system to default state...'
	@bash /usr/local/sbin/zfs-import-scan-enable.sh
	@echo '✅ System reverted to default state.'

clean:
	@echo 'Cleaning up installed files...'
	rm -f /usr/local/sbin/zfs-import-scan-{disable,enable,watchdog-verify}.sh
	rm -f /usr/local/lib/{assert,log,shell_modes,traps}.sh
	@echo '✅ All files have been removed.'

uninstall: clean
	@echo '✅ Uninstallation complete.'