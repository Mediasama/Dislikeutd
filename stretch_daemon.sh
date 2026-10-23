#!/system/bin/sh
# ================================================================
# AxManager - 4:3 Stretch Daemon Service (Android 13+)
# Background App Monitoring & Geometry Switcher
# ================================================================

CONF_DIR="/data/local/tmp"
[ -w "$CONF_DIR" ] || CONF_DIR="/tmp"
[ -w "$CONF_DIR" ] || CONF_DIR="/sdcard"

CONF_FILE="${CONF_DIR}/ax_stretch.conf"
DAEMON_PID_FILE="${CONF_DIR}/ax_stretch_daemon.pid"
STATE_FILE="${CONF_DIR}/ax_stretch_state"

start_daemon() {
    if [ -f "$DAEMON_PID_FILE" ]; then
        OLD_PID=$(cat "$DAEMON_PID_FILE" 2>/dev/null)
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            echo "[StretchDaemon] Daemon is already running (PID: $OLD_PID)"
            return 0
        fi
    fi

    (
        trap 'rm -f "$DAEMON_PID_FILE"; exit 0' INT TERM EXIT
        echo "$$" > "$DAEMON_PID_FILE"
        echo "[StretchDaemon] Background monitor started (PID: $$)"

        IS_STRETCHED=0

        while true; do
            if [ -f "$CONF_FILE" ]; then
                . "$CONF_FILE"
            fi

            TARGET_APP="${TARGET_APP:-com.axlebolt.standoff2}"
            STRETCH_SIZE="${STRETCH_SIZE:-1440x1080}"
            STRETCH_DENSITY="${STRETCH_DENSITY:-reset}"

            CURRENT_FOCUS=$(dumpsys window 2>/dev/null | grep -E 'mCurrentFocus|mFocusedApp' | head -n 1)

            if echo "$CURRENT_FOCUS" | grep -q "$TARGET_APP"; then
                if [ "$IS_STRETCHED" -eq 0 ]; then
                    echo "[StretchDaemon] Target app $TARGET_APP focused! Applying 4:3 stretch ($STRETCH_SIZE)..."

                    am compat disable OVERRIDE_MIN_ASPECT_RATIO "$TARGET_APP" 2>/dev/null || true
                    am compat disable OVERRIDE_MIN_ASPECT_RATIO_EXCLUDE_PORTRAIT_FULLSCREEN "$TARGET_APP" 2>/dev/null || true
                    am compat disable SIZE_COMPAT_RESTART_BUTTON "$TARGET_APP" 2>/dev/null || true
                    settings put global enable_freeform_support 1 2>/dev/null || true

                    wm size "$STRETCH_SIZE" 2>/dev/null || true
                    if [ -n "$STRETCH_DENSITY" ] && [ "$STRETCH_DENSITY" != "reset" ]; then
                        wm density "$STRETCH_DENSITY" 2>/dev/null || true
                    fi

                    echo "2" > "$STATE_FILE"
                    IS_STRETCHED=1
                fi
            else
                if [ "$IS_STRETCHED" -eq 1 ]; then
                    echo "[StretchDaemon] Target app $TARGET_APP lost focus. Restoring display geometry..."
                    wm size reset 2>/dev/null || true
                    wm density reset 2>/dev/null || true
                    rm -f "$STATE_FILE"
                    IS_STRETCHED=0
                fi
            fi

            sleep 1.5
        done
    ) &

    echo "[StretchDaemon] Service launched in background."
}

stop_daemon() {
    if [ -f "$DAEMON_PID_FILE" ]; then
        PID=$(cat "$DAEMON_PID_FILE" 2>/dev/null)
        if [ -n "$PID" ]; then
            kill -9 "$PID" 2>/dev/null || true
            echo "[StretchDaemon] Daemon process $PID terminated."
        fi
        rm -f "$DAEMON_PID_FILE"
    fi
    wm size reset 2>/dev/null || true
    wm density reset 2>/dev/null || true
    rm -f "$STATE_FILE"
    echo "[StretchDaemon] Daemon stopped and screen geometry restored."
}

status_daemon() {
    if [ -f "$DAEMON_PID_FILE" ]; then
        PID=$(cat "$DAEMON_PID_FILE" 2>/dev/null)
        if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
            echo "RUNNING (PID: $PID)"
            return 0
        fi
    fi
    echo "STOPPED"
    return 1
}

CMD="${1:-start}"

case "$CMD" in
    start) start_daemon ;;
    stop) stop_daemon ;;
    status) status_daemon ;;
    restart) stop_daemon; sleep 1; start_daemon ;;
    *) echo "Usage: $0 {start|stop|status|restart}"; exit 1 ;;
esac

exit 0
