#!/bin/sh
# Game Stretch Pro (Non-Root) - service.sh
# Background service for auto-detecting target games and dynamically applying aspect ratio stretch

DIR="$(cd "$(dirname "$0")" && pwd)"
CONF_DIR="${DIR}"
if [ ! -w "${CONF_DIR}" ]; then
    CONF_DIR="/sdcard/Android/GameStretchPro"
fi

CONF_FILE="${CONF_DIR}/config.conf"
PKG_FILE="${CONF_DIR}/packages.list"
LOG_FILE="${CONF_DIR}/stretch.log"
PID_FILE="/tmp/game_stretch_service.pid"

# Single instance guard
if [ -f "${PID_FILE}" ]; then
    OLD_PID="$(cat "${PID_FILE}" 2>/dev/null)"
    if [ -n "${OLD_PID}" ] && kill -0 "${OLD_PID}" 2>/dev/null; then
        echo "Game Stretch Pro daemon is already running (PID: ${OLD_PID})."
        exit 0
    fi
fi
echo "$$" > "${PID_FILE}"

log() {
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[${timestamp}] [Service] $1" >> "${LOG_FILE}"
}

log "Daemon service started."

LAST_ACTIVE_PKG=""

# Foreground package detection loop
while true; do
    sleep 3

    if [ ! -f "${PKG_FILE}" ]; then
        continue
    fi

    # Read current config
    M1=1; M2=1; M3=1; M4=1
    if [ -f "${CONF_FILE}" ]; then
        . "${CONF_FILE}" 2>/dev/null || true
    fi

    # Detect current foreground window package
    CURRENT_PKG="$(dumpsys window 2>/dev/null | grep -E 'mCurrentFocus|mFocusedApp' | head -n 1 | sed -n 's/.* \([^/ ]*\)\/.*/\1/p')"
    if [ -z "${CURRENT_PKG}" ]; then
        CURRENT_PKG="$(dumpsys activity recents 2>/dev/null | grep -E 'realActivity=' | head -n 1 | sed -n 's/.*realActivity=\([^/ ]*\).*/\1/p')"
    fi

    if [ -z "${CURRENT_PKG}" ]; then
        continue
    fi

    # Check if CURRENT_PKG is in target list
    IS_TARGET=0
    while IFS= read -r pkg || [ -n "${pkg}" ]; do
        [ -z "${pkg}" ] && continue
        case "${pkg}" in \#*) continue ;; esac
        if [ "${pkg}" = "${CURRENT_PKG}" ]; then
            IS_TARGET=1
            break
        fi
    done < "${PKG_FILE}"

    if [ "${IS_TARGET}" -eq 1 ]; then
        if [ "${LAST_ACTIVE_PKG}" != "${CURRENT_PKG}" ]; then
            log "Target game launched: ${CURRENT_PKG}. Applying dynamic aspect ratio stretch..."

            # Execute main.sh apply for active package
            sh "${DIR}/main.sh" apply "${CURRENT_PKG}" >/dev/null 2>&1 || true
            LAST_ACTIVE_PKG="${CURRENT_PKG}"
        fi
    else
        if [ -n "${LAST_ACTIVE_PKG}" ]; then
            log "Game exited (${LAST_ACTIVE_PKG}). System UI display parameters clean."
            LAST_ACTIVE_PKG=""
        fi
    fi
done
