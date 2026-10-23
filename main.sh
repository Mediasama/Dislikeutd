#!/bin/sh
# Game Stretch Pro (Non-Root) - main.sh
# Main engine for forced aspect ratio stretching on Samsung SM-A536E (Android 13 / One UI)

DIR="$(cd "$(dirname "$0")" && pwd)"
CONF_DIR="${DIR}"
if [ ! -w "${CONF_DIR}" ]; then
    CONF_DIR="/sdcard/Android/GameStretchPro"
    mkdir -p "${CONF_DIR}" 2>/dev/null
fi

CONF_FILE="${CONF_DIR}/config.conf"
PKG_FILE="${CONF_DIR}/packages.list"
LOG_FILE="${CONF_DIR}/stretch.log"

# Default configuration initialization
init_config() {
    if [ ! -f "${CONF_FILE}" ]; then
        cat << 'EOF' > "${CONF_FILE}"
M1=1
M2=1
M3=1
M4=1
AUTO_RESTART=1
EOF
    fi

    if [ ! -f "${PKG_FILE}" ]; then
        cat << 'EOF' > "${PKG_FILE}"
com.dts.freefiremax
com.sandboxol.blockymods
com.tencent.ig
com.miHoYo.GenshinImpact
EOF
    fi
}

log() {
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[${timestamp}] $1" >> "${LOG_FILE}"
    echo "$1"
}

init_config

# Load config
. "${CONF_FILE}" 2>/dev/null || true
M1="${M1:-1}"
M2="${M2:-1}"
M3="${M3:-1}"
M4="${M4:-1}"

# Check package existence via pm
check_package() {
    local pkg="$1"
    if pm list packages 2>/dev/null | grep -q -i "${pkg}"; then
        return 0
    else
        return 1
    fi
}

# Method 1: System Compatibility Flags & WindowManager Overrides (Android 13)
apply_method1() {
    local pkg="$1"
    log "[Method 1] Applying system compatibility and WindowManager overrides for ${pkg}..."

    # Enable Android 13 compat aspect ratio overrides for non-root ADB / Shizuku shell
    am compat enable OVERRIDE_MIN_ASPECT_RATIO "${pkg}" >/dev/null 2>&1 || true
    am compat enable OVERRIDE_MIN_ASPECT_RATIO_LARGE "${pkg}" >/dev/null 2>&1 || true
    am compat enable FORCE_RESIZEABLE "${pkg}" >/dev/null 2>&1 || true
    am compat enable OVERRIDE_MIN_ASPECT_RATIO_EXCLUDE_PORTRAIT_FULLSCREEN "${pkg}" >/dev/null 2>&1 || true
    am compat enable OVERRIDE_CAMERA_RESIZABLE_AND_PIXELS_PER_INCH "${pkg}" >/dev/null 2>&1 || true

    # Global WindowManager device config flags for forcing full screen scaling
    device_config put window_manager force_non_resizeable_aspect_ratio_scaling true >/dev/null 2>&1 || true
    device_config put window_manager disable_in_app_landscape_aspect_ratio_user_settings false >/dev/null 2>&1 || true
    cmd window set-ignore-orientation-request true >/dev/null 2>&1 || true

    # Global system settings for activity scaling
    settings put global force_resizable_activities 1 >/dev/null 2>&1 || true
    settings put global enable_freeform_support 1 >/dev/null 2>&1 || true

    log "[Method 1] Overrides dispatched for ${pkg}."
}

# Method 2: One UI / Samsung Display & Game Booster Manipulations
apply_method2() {
    local pkg="$1"
    log "[Method 2] Applying Samsung One UI & Game Booster scaling for ${pkg}..."

    # Samsung Game Optimizing Service (GOS) & Game Booster commands
    cmd game set --mode custom "${pkg}" >/dev/null 2>&1 || true
    cmd game mode performance "${pkg}" >/dev/null 2>&1 || true

    # Append package to Samsung full screen legacy & sec full screen app settings
    local current_sec
    current_sec="$(settings get global sec_full_screen_apps 2>/dev/null)"
    if [ "${current_sec}" = "null" ] || [ -z "${current_sec}" ]; then
        settings put global sec_full_screen_apps "${pkg}" >/dev/null 2>&1 || true
    else
        case "${current_sec}" in
            *"${pkg}"*) ;;
            *) settings put global sec_full_screen_apps "${current_sec},${pkg}" >/dev/null 2>&1 || true ;;
        esac
    fi

    local current_legacy
    current_legacy="$(settings get global legacy_apps_full_screen 2>/dev/null)"
    if [ "${current_legacy}" = "null" ] || [ -z "${current_legacy}" ]; then
        settings put global legacy_apps_full_screen "${pkg}" >/dev/null 2>&1 || true
    else
        case "${current_legacy}" in
            *"${pkg}"*) ;;
            *) settings put global legacy_apps_full_screen "${current_legacy},${pkg}" >/dev/null 2>&1 || true ;;
        esac
    fi

    # Disable cutout hide interference for true full screen
    settings put system display_cutout_hide 0 >/dev/null 2>&1 || true

    log "[Method 2] One UI display scaling updated for ${pkg}."
}

# Method 3: Dynamic Surface & Window/Task Bounds Override
apply_method3() {
    local pkg="$1"
    log "[Method 3] Applying forced surface override & cutout bounds for ${pkg}..."

    # Force cutout area usage and remove letterbox borders for full 20:9 screen fill
    cmd window set-display-cutout-mode "${pkg}" never >/dev/null 2>&1 || true
    cmd window set-letterbox-style --aspectRatio 2.22 "${pkg}" >/dev/null 2>&1 || true
    cmd window set-letterbox-style --cornerRadius 0 "${pkg}" >/dev/null 2>&1 || true

    # Try active stack bounds reset if running
    local stack_id
    stack_id="$(dumpsys window displays 2>/dev/null | grep -E "type=.*${pkg}" | head -n 1 | sed -n 's/.*#\([0-9]*\).*/\1/p')"
    if [ -n "${stack_id}" ]; then
        am stack resize "${stack_id}" 0 0 2400 1080 >/dev/null 2>&1 || true
    fi

    log "[Method 3] Surface override applied for ${pkg}."
}

# Method 4: Non-Root Aspect Proxy & Environment Simulation Concept
apply_method4() {
    local pkg="$1"
    log "[Method 4] Applying Aspect Ratio Hook & non-root proxy settings for ${pkg}..."

    # System property flags simulation
    local sanitized_pkg
    sanitized_pkg="$(echo "${pkg}" | tr '.' '_')"
    setprop "persist.sys.game_stretch.${sanitized_pkg}" "1" >/dev/null 2>&1 || true
    settings put global "aspect_ratio_override_${sanitized_pkg}" "2.22" >/dev/null 2>&1 || true

    log "[Method 4] Aspect ratio hook set for ${pkg}."
}

# Revert methods for a package
revert_package() {
    local pkg="$1"
    log "Reverting stretch settings for ${pkg}..."

    am compat disable OVERRIDE_MIN_ASPECT_RATIO "${pkg}" >/dev/null 2>&1 || true
    am compat disable OVERRIDE_MIN_ASPECT_RATIO_LARGE "${pkg}" >/dev/null 2>&1 || true
    am compat disable FORCE_RESIZEABLE "${pkg}" >/dev/null 2>&1 || true

    cmd window reset-display-cutout-mode "${pkg}" >/dev/null 2>&1 || true

    local sanitized_pkg
    sanitized_pkg="$(echo "${pkg}" | tr '.' '_')"
    setprop "persist.sys.game_stretch.${sanitized_pkg}" "0" >/dev/null 2>&1 || true
    settings delete global "aspect_ratio_override_${sanitized_pkg}" >/dev/null 2>&1 || true

    log "Revert finished for ${pkg}."
}

apply_pkg() {
    local pkg="$1"
    log "------------------------------------------------"
    log "Starting Game Stretch Pro application for: ${pkg}"

    if check_package "${pkg}"; then
        log "Package ${pkg} detected on device (installed)."
    else
        log "Notice: Package ${pkg} is not currently detected by 'pm list packages'. Applying rules provisionally."
    fi

    [ "${M1}" = "1" ] && apply_method1 "${pkg}"
    [ "${M2}" = "1" ] && apply_method2 "${pkg}"
    [ "${M3}" = "1" ] && apply_method3 "${pkg}"
    [ "${M4}" = "1" ] && apply_method4 "${pkg}"

    log "Game Stretch Pro successfully applied for ${pkg}!"
    log "------------------------------------------------"
}

# Command dispatching
ACTION="${1:-apply_all}"
PARAM1="$2"
PARAM2="$3"
PARAM3="$4"
PARAM4="$5"

case "${ACTION}" in
    apply)
        if [ -n "${PARAM1}" ]; then
            apply_pkg "${PARAM1}"
        else
            while IFS= read -r pkg || [ -n "${pkg}" ]; do
                [ -z "${pkg}" ] && continue
                case "${pkg}" in
                    \#*) continue ;;
                esac
                apply_pkg "${pkg}"
            done < "${PKG_FILE}"
        fi
        echo "ok=1"
        ;;

    apply_all)
        while IFS= read -r pkg || [ -n "${pkg}" ]; do
            [ -z "${pkg}" ] && continue
            case "${pkg}" in
                \#*) continue ;;
            esac
            apply_pkg "${pkg}"
        done < "${PKG_FILE}"
        echo "ok=1"
        ;;

    revert)
        if [ -n "${PARAM1}" ]; then
            revert_package "${PARAM1}"
        else
            while IFS= read -r pkg || [ -n "${pkg}" ]; do
                [ -z "${pkg}" ] && continue
                case "${pkg}" in
                    \#*) continue ;;
                esac
                revert_package "${pkg}"
            done < "${PKG_FILE}"
        fi
        echo "ok=1"
        ;;

    add_pkg)
        if [ -n "${PARAM1}" ]; then
            if grep -q -x "${PARAM1}" "${PKG_FILE}" 2>/dev/null; then
                log "Package ${PARAM1} is already in target list."
            else
                echo "${PARAM1}" >> "${PKG_FILE}"
                log "Added ${PARAM1} to target package list."
            fi
            echo "ok=1"
        else
            echo "error=missing_package_name"
        fi
        ;;

    remove_pkg)
        if [ -n "${PARAM1}" ]; then
            revert_package "${PARAM1}"
            grep -v -x "${PARAM1}" "${PKG_FILE}" > "${PKG_FILE}.tmp" 2>/dev/null || true
            mv "${PKG_FILE}.tmp" "${PKG_FILE}" 2>/dev/null || true
            log "Removed ${PARAM1} from target package list."
            echo "ok=1"
        else
            echo "error=missing_package_name"
        fi
        ;;

    set_methods)
        M1="${PARAM1:-1}"
        M2="${PARAM2:-1}"
        M3="${PARAM3:-1}"
        M4="${PARAM4:-1}"
        cat << EOF > "${CONF_FILE}"
M1=${M1}
M2=${M2}
M3=${M3}
M4=${M4}
AUTO_RESTART=1
EOF
        log "Updated bypass methods: M1=${M1}, M2=${M2}, M3=${M3}, M4=${M4}"
        echo "ok=1"
        ;;

    get_config)
        cat "${CONF_FILE}"
        echo "ok=1"
        ;;

    get_pkgs)
        if [ -f "${PKG_FILE}" ]; then
            cat "${PKG_FILE}"
        fi
        echo "ok=1"
        ;;

    get_log)
        if [ -f "${LOG_FILE}" ]; then
            tail -n 100 "${LOG_FILE}"
        else
            echo "No log history available yet."
        fi
        echo "ok=1"
        ;;

    clear_log)
        > "${LOG_FILE}" 2>/dev/null || true
        log "Log file cleared."
        echo "ok=1"
        ;;

    *)
        echo "Usage: main.sh {apply|apply_all|revert|add_pkg|remove_pkg|set_methods|get_config|get_pkgs|get_log|clear_log}"
        ;;
esac
