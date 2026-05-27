# Source this file (do not execute) to use the folder-local Hermes build
# in your current shell:
#
#   source env.sh
#   hermes -e "print('hi')"
#
# This only modifies PATH for the current shell session.

# Resolve our own directory whether sourced from bash or zsh.
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  __HERMES_ENV_SRC="${BASH_SOURCE[0]}"
elif [ -n "${(%):-%x}" ] 2>/dev/null; then
  __HERMES_ENV_SRC="${(%):-%x}"
else
  __HERMES_ENV_SRC="$0"
fi

__HERMES_ENV_DIR="$(cd "$(dirname "${__HERMES_ENV_SRC}")" && pwd)"
__HERMES_BIN="${__HERMES_ENV_DIR}/hermes/build/bin"

if [ -x "${__HERMES_BIN}/hermes" ]; then
  case ":$PATH:" in
    *":${__HERMES_BIN}:"*) ;;
    *) export PATH="${__HERMES_BIN}:$PATH" ;;
  esac
  echo "hermes/build/bin added to PATH ($(hermes --version 2>/dev/null | head -n1))"
else
  echo "hermes/build/bin not found at ${__HERMES_BIN}" >&2
  echo "Run ./install.sh first." >&2
fi

unset __HERMES_ENV_SRC __HERMES_ENV_DIR __HERMES_BIN
