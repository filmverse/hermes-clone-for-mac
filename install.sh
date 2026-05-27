#!/usr/bin/env bash
# Isolated Hermes (RN 0.85.3) build for macOS.
# Builds into ./hermes/build/bin/ — nothing is installed system-wide.
# Re-runnable: safe to invoke multiple times.

set -euo pipefail

# ---- config ----------------------------------------------------------------
HERMES_TAG="hermes-v250829098.0.10"
HERMES_REPO="https://github.com/facebook/hermes.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_DIR="${SCRIPT_DIR}/hermes"
BUILD_DIR="${HERMES_DIR}/build"
ARCH="$(uname -m)"
JOBS="$(sysctl -n hw.ncpu)"

log() { printf '==> %s\n' "$*"; }
err() { printf 'error: %s\n' "$*" >&2; }

# ---- platform guard --------------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  err "This script targets macOS only (uname -s = $(uname -s))."
  exit 1
fi

# ---- cmake -----------------------------------------------------------------
if command -v cmake >/dev/null 2>&1; then
  log "cmake already present: $(cmake --version | head -n1)"
else
  if ! command -v brew >/dev/null 2>&1; then
    err "cmake is missing and Homebrew is not installed."
    err "Install Homebrew from https://brew.sh first, then re-run this script."
    exit 1
  fi
  log "Installing cmake via Homebrew"
  brew install cmake
fi

# ---- clone -----------------------------------------------------------------
if [[ -d "${HERMES_DIR}/.git" ]]; then
  log "Hermes already cloned at ${HERMES_DIR}; skipping clone"
else
  log "Cloning Hermes into ${HERMES_DIR}"
  git clone "${HERMES_REPO}" "${HERMES_DIR}"
fi

# ---- checkout tag ----------------------------------------------------------
log "Fetching tags and checking out ${HERMES_TAG}"
git -C "${HERMES_DIR}" fetch --tags --quiet
git -C "${HERMES_DIR}" checkout "${HERMES_TAG}"

# ---- cmake configure -------------------------------------------------------
log "Configuring CMake (arch: ${ARCH}, build type: Release)"
cmake -S "${HERMES_DIR}" -B "${BUILD_DIR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES="${ARCH}"

# ---- build -----------------------------------------------------------------
log "Building with ${JOBS} parallel jobs (first build ~15-30 min)"
cmake --build "${BUILD_DIR}" -j"${JOBS}"

# ---- smoke test ------------------------------------------------------------
# Hermes' CLI takes file args (no -e flag), so we run a small temp script.
log "Smoke test"
SMOKE_JS="$(mktemp -t hermes-smoke)"
trap 'rm -f "${SMOKE_JS}"' EXIT
printf "print('hello from hermes');\n" > "${SMOKE_JS}"
"${BUILD_DIR}/bin/hermes" "${SMOKE_JS}"

# ---- verify ----------------------------------------------------------------
log "Versions"
"${BUILD_DIR}/bin/hermes" --version
log "Upstream commit: $(git -C "${HERMES_DIR}" rev-parse HEAD)"

cat <<MSG

Done. Binaries are at:
  ${BUILD_DIR}/bin/hermes
  ${BUILD_DIR}/bin/hermesc
  ${BUILD_DIR}/bin/hbcdump

To use Hermes in your current shell:
  source ${SCRIPT_DIR}/env.sh
  echo "print('hi');" > hi.js && hermes hi.js

Or call binaries directly without modifying PATH:
  echo "print('hi');" > hi.js && ${BUILD_DIR}/bin/hermes hi.js

To uninstall, just remove this folder:
  rm -rf ${SCRIPT_DIR}
MSG
