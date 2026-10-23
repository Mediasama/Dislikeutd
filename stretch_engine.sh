#!/system/bin/sh
# ================================================================
# AxManager - 4:3 Screen Stretch & Resolution Engine (Android 13+)
# Rootless Shell Engine for Axeron / Ax Manager
# Author: AxManager FPS Team
# ================================================================

CONF_DIR="/data/local/tmp"
[ -w "$CONF_DIR" ] || CONF_DIR="/tmp"
[ -w "$CONF_DIR" ] || CONF_DIR="/sdcard"

CONF_FILE="${CONF_DIR}/ax_stretch.conf"
STATE_FILE="${CONF_DIR}/ax_stretch_state"
DAEMON_PID_FILE="${CONF_DIR}/ax_stretch_daemon.pid"

STRETCH_METHOD="${STRETCH_METHOD:-1}"
TARGET_APP="${TARGET_APP:-com.axlebolt.standoff2}"
STRETCH_SIZE="${STRETCH_SIZE:-1440x1080}"
STRETCH_DENSITY="${STRETCH_DENSITY:-reset}"
TIMING_DELAY="${TIMING_DELAY:-2500}"

if [ -f "$CONF_FILE" ]; then
    . "$CONF_FILE"
fi

log_msg() {
    echo "[StretchEngine] $1"
}

save_config() {
    cat <<EOF > "$CONF_FILE"
STRETCH_METHOD="$STRETCH_METHOD"
TARGET_APP="$TARGET_APP"
STRETCH_SIZE="$STRETCH_SIZE"
STRETCH_DENSITY="$STRETCH_DENSITY"
TIMING_DELAY="$TIMING_DELAY"
EOF
    log_msg "Configuration saved to $CONF_FILE"
}

disable_android13_letterboxing() {
    APP="$1"
    [ -z "$APP" ] && return
    log_msg "Bypassing Android 13+ App Compat Letterboxing for $APP..."
    am compat disable OVERRIDE_MIN_ASPECT_RATIO "$APP" 2>/dev/null || true
    am compat disable OVERRIDE_MIN_ASPECT_RATIO_EXCLUDE_PORTRAIT_FULLSCREEN "$APP" 2>/dev/null || true
    am compat disable SIZE_COMPAT_RESTART_BUTTON "$APP" 2>/dev/null || true
    settings put global enable_freeform_support 1 2>/dev/null || true
    settings put global force_resizable_activities 1 2>/dev/null || true
    settings put global game_compat_mode_enabled 1 2>/dev/null || true
}

apply_method_1() {
    log_msg "Applying Method 1: Direct Rescale + App Compat Bypass"
    disable_android13_letterboxing "$TARGET_APP"
    wm size "$STRETCH_SIZE" 2>/dev/null || true
    if [ -n "$STRETCH_DENSITY" ] && [ "$STRETCH_DENSITY" != "reset" ]; then
        wm density "$STRETCH_DENSITY" 2>/dev/null || true
    fi
    echo "1" > "$STATE_FILE"
    log_msg "Method 1 applied: $STRETCH_SIZE ($STRETCH_DENSITY DPI)"
}

apply_method_2() {
    log_msg "Applying Method 2: Launching Background Stretch Daemon Service"
    save_config
    SCRIPT_DIR="$(dirname "$0")"
    sh "$CONF_DIR/stretch_daemon.sh" start 2>/dev/null || sh "$SCRIPT_DIR/stretch_daemon.sh" start 2>/dev/null || true
}

apply_method_3() {
    log_msg "Applying Method 3: Freeform Multi-Window Aspect Ratio Hack"
    disable_android13_letterboxing "$TARGET_APP"
    wm size "$STRETCH_SIZE" 2>/dev/null || true
    if [ -n "$STRETCH_DENSITY" ] && [ "$STRETCH_DENSITY" != "reset" ]; then
        wm density "$STRETCH_DENSITY" 2>/dev/null || true
    fi
    am start --windowingMode 5 "$TARGET_APP" 2>/dev/null || monkey -p "$TARGET_APP" -c android.intent.category.LAUNCHER 1 2>/dev/null || true
    echo "3" > "$STATE_FILE"
    log_msg "Method 3 applied: Freeform Hack triggered for $TARGET_APP"
}

apply_method_4() {
    log_msg "Applying Method 4: Virtual Display Overlay Simulation"
    disable_android13_letterboxing "$TARGET_APP"
    DPI_VAL="${STRETCH_DENSITY:-260}"
    [ "$DPI_VAL" = "reset" ] && DPI_VAL="260"
    OVERLAY_DEV="${STRETCH_SIZE}/${DPI_VAL}"
    settings put global overlay_display_devices "$OVERLAY_DEV" 2>/dev/null || true
    echo "4" > "$STATE_FILE"
    log_msg "Method 4 applied: overlay_display_devices=$OVERLAY_DEV"
}

apply_method_5() {
    log_msg "Applying Method 5: Dynamic Load-Timing Switch Exploit"
    disable_android13_letterboxing "$TARGET_APP"
    monkey -p "$TARGET_APP" -c android.intent.category.LAUNCHER 1 2>/dev/null || am start -n "$TARGET_APP" 2>/dev/null || true

    MS="${TIMING_DELAY:-2500}"
    log_msg "Waiting ${MS}ms for game splash screen transition..."

    SEC=$((MS / 1000))
    [ "$SEC" -lt 1 ] && SEC=1
    sleep "$SEC"

    wm size "$STRETCH_SIZE" 2>/dev/null || true
    if [ -n "$STRETCH_DENSITY" ] && [ "$STRETCH_DENSITY" != "reset" ]; then
        wm density "$STRETCH_DENSITY" 2>/dev/null || true
    fi
    echo "5" > "$STATE_FILE"
    log_msg "Method 5 applied: Stretch size set post-launch!"
}

reset_geometry() {
    log_msg "Resetting screen resolution and density..."
    wm size reset 2>/dev/null || true
    wm density reset 2>/dev/null || true
    settings delete global overlay_display_devices 2>/dev/null || settings put global overlay_display_devices "none" 2>/dev/null || true

    if [ -f "$DAEMON_PID_FILE" ]; then
        PID=$(cat "$DAEMON_PID_FILE" 2>/dev/null)
        [ -n "$PID" ] && kill -9 "$PID" 2>/dev/null || true
        rm -f "$DAEMON_PID_FILE"
    fi

    rm -f "$STATE_FILE"
    log_msg "Display reset to default system geometry."
}

get_status() {
    WM_SIZE=$(wm size 2>/dev/null | tr '\n' ' ')
    WM_DENSITY=$(wm density 2>/dev/null | tr '\n' ' ')
    FOCUS_APP=$(dumpsys window 2>/dev/null | grep -E 'mCurrentFocus|mFocusedApp' | head -n 1 | cut -d'/' -f1 | rev | cut -d' ' -f1 | rev)
    OVERLAY_DEV=$(settings get global overlay_display_devices 2>/dev/null)

    DAEMON_RUNNING="0"
    if [ -f "$DAEMON_PID_FILE" ]; then
        PID=$(cat "$DAEMON_PID_FILE" 2>/dev/null)
        if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
            DAEMON_RUNNING="1"
        fi
    fi

    ACTIVE_STATE="0"
    [ -f "$STATE_FILE" ] && ACTIVE_STATE=$(cat "$STATE_FILE" 2>/dev/null)

    cat <<EOF
{
  "wm_size": "${WM_SIZE:-Normal}",
  "wm_density": "${WM_DENSITY:-Default}",
  "focus_app": "${FOCUS_APP:-None}",
  "overlay_devices": "${OVERLAY_DEV:-None}",
  "daemon_running": ${DAEMON_RUNNING},
  "active_method": "${ACTIVE_STATE}",
  "target_app": "${TARGET_APP}",
  "stretch_size": "${STRETCH_SIZE}",
  "stretch_density": "${STRETCH_DENSITY}"
}
EOF
}

ACTION="${1:-apply}"

case "$ACTION" in
    apply)
        save_config
        case "$STRETCH_METHOD" in
            1) apply_method_1 ;;
            2) apply_method_2 ;;
            3) apply_method_3 ;;
            4) apply_method_4 ;;
            5) apply_method_5 ;;
            *) apply_method_1 ;;
        esac
        ;;
    method1) STRETCH_METHOD=1; save_config; apply_method_1 ;;
    method2) STRETCH_METHOD=2; save_config; apply_method_2 ;;
    method3) STRETCH_METHOD=3; save_config; apply_method_3 ;;
    method4) STRETCH_METHOD=4; save_config; apply_method_4 ;;
    method5) STRETCH_METHOD=5; save_config; apply_method_5 ;;
    reset) reset_geometry ;;
    status) get_status ;;
    start_daemon)
        save_config
        SCRIPT_DIR="$(dirname "$0")"
        sh "$CONF_DIR/stretch_daemon.sh" start 2>/dev/null || sh "$SCRIPT_DIR/stretch_daemon.sh" start 2>/dev/null || true
        ;;
    stop_daemon)
        SCRIPT_DIR="$(dirname "$0")"
        sh "$CONF_DIR/stretch_daemon.sh" stop 2>/dev/null || sh "$SCRIPT_DIR/stretch_daemon.sh" stop 2>/dev/null || true
        ;;
    config)
        save_config
        ;;
    *)
        log_msg "Usage: $0 {apply|method1|method2|method3|method4|method5|reset|status|start_daemon|stop_daemon|config}"
        exit 1
        ;;
esac

exit 0
