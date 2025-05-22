# Shared Bash Library

This directory contains reusable Bash library modules intended to support shell scripting across Linux environments. These utilities are not limited to automation workflows—they can be used in any Bash script that benefits from standardized logging, error handling, and modular structure.

## 📚 Purpose

The libraries in this directory are designed to:

* Standardize logging across all scripts.
* Provide safe and consistent error and signal trapping.
* Offer reusable, tested, and composable shell utilities.
* Enforce fail-fast, production-safe scripting practices.
* Validate script prerequisites (e.g., root access, command existence)

## 📦 Library Modules

| File             | Purpose                                                                           |
|------------------|-----------------------------------------------------------------------------------|
| `log.sh`         | Unified logging for stdout and syslog                                             |
| `traps.sh`       | Signal and error trapping for safe script teardown                                |
| `shell_modes.sh` | Explicitly enables strict or debug mode per script                                |
| `assert.sh`      | Runtime assertions for files, directories, commands, and root user checks         |

All libraries are meant to be sourced, not executed directly.

---

## 🧩 Example Usage

### `log.sh`

```shell
readonly LOG_TAG="<tag_name>"
source /usr/local/lib/log.sh

log_info "Script started"
log_warn "Something might be off"
log_error "Something went wrong"
```

### `traps.sh`

```shell
readonly TRAP_TAG="<tag_name>"
source /usr/local/lib/traps.sh
# Automatically sets:
# trap 'catch_err $LINENO $?' ERR
# trap 'on_exit' EXIT INT TERM
```

### `shell_modes.sh`

```shell
source /usr/local/lib/shell_modes.sh
enable_strict_mode
```

---

## 🛠 Installation

To make these libraries globally available:

```shell
sudo mkdir -p /usr/local/lib
sudo cp *.sh /usr/local/lib/
sudo chmod 644 /usr/local/lib/*.sh
sudo chown root:root /usr/local/lib/*.sh
```

Make sure the containing directory is also readable:

```shell
sudo chmod 755 /usr/local/lib
```

Then source them at the top of any script that needs them.

---

## 🧱 Philosophy

These libraries follow key design principles:

* 🔒 Fail-fast and error-aware
* 🧼 Modular and composable
* 🛡 Defensive by default
* 🧠 Designed for general-purpose shell scripting