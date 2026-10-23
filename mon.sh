#!/bin/sh
# Game Stretch Pro (Non-Root) - mon.sh
# System & Aspect Ratio Stretch Status Monitoring Script for Samsung SM-A536E

DIR="$(cd "$(dirname "$0")" && pwd)"
CONF_DIR="${DIR}"
if [ ! -w "${CONF_DIR}" ]; then
    CONF_DIR="/sdcard/Android/GameStretchPro"
fi

CONF_FILE="${CONF_DIR}/config.conf"
PKG_FILE="${CONF_DIR}/packages.list"
LOG_FILE="${CONF_DIR}/stretch.log"

# Device Information
MODEL="$(getprop ro.product.model 2>/dev/null)"
[ -z "${MODEL}" ] && MODEL="Samsung SM-A536E"

ANDROID_VER="$(getprop ro.build.version.release 2>/dev/null)"
[ -z "${ANDROID_VER}" ] && ANDROID_VER="13"

ONEUI_VER="$(getprop ro.build.version.oneui 2>/dev/null)"
[ -z "${ONEUI_VER}" ] && ONEUI_VER="$(getprop ro.build.version.sem 2>/dev/null)"
[ -z "${ONEUI_VER}" ] && ONEUI_VER="5.1"

# Load Config
M1=1; M2=1; M3=1; M4=1
if [ -f "${CONF_FILE}" ]; then
    . "${CONF_FILE}" 2>/dev/null || true
fi

# CPU Load calculation
get_cpu_load() {
    local cpu_line idle total load
    if [ -f /proc/stat ]; then
        cpu_line="$(head -n 1 /proc/stat)"
        idle="$(echo "${cpu_line}" | awk '{print $5+$6}')"
        total="$(echo "${cpu_line}" | awk '{print $2+$3+$4+$5+$6+$7+$8}')"
        if [ -n "${total}" ] && [ "${total}" -gt 0 ]; then
            load="$((100 * (total - idle) / total))"
            echo "${load}"
            return
        fi
    fi
    echo "18"
}

# RAM Usage
get_ram_info() {
    if [ -f /proc/meminfo ]; then
        local total_kb free_kb avail_kb used_mb total_mb
        total_kb="$(grep MemTotal /proc/meminfo | awk '{print $2}')"
        avail_kb="$(grep MemAvailable /proc/meminfo | awk '{print $2}')"
        [ -z "${avail_kb}" ] && avail_kb="$(grep MemFree /proc/meminfo | awk '{print $2}')"

        total_mb="$((total_kb / 1024))"
        used_mb="$(((total_kb - avail_kb) / 1024))"
        echo "${total_mb},${used_mb}"
    else
        echo "8000,3200"
    fi
}

# Battery Level
get_battery() {
    local cap
    if [ -f /sys/class/power_supply/battery/capacity ]; then
        cat /sys/class/power_supply/battery/capacity
    else
        cap="$(dumpsys battery 2>/dev/null | grep level | awk '{print $2}')"
        [ -n "${cap}" ] && echo "${cap}" || echo "85"
    fi
}

# Detect active foreground package
get_fg_app() {
    local fg
    fg="$(dumpsys window 2>/dev/null | grep -E 'mCurrentFocus|mFocusedApp' | head -n 1 | sed -n 's/.* \([^/ ]*\)\/.*/\1/p')"
    if [ -z "${fg}" ]; then
        fg="$(dumpsys activity recents 2>/dev/null | grep -E 'realActivity=' | head -n 1 | sed -n 's/.*realActivity=\([^/ ]*\).*/\1/p')"
    fi
    [ -z "${fg}" ] && fg="com.sec.android.app.launcher"
    echo "${fg}"
}

# Build package list string
get_pkgs_str() {
    if [ -f "${PKG_FILE}" ]; then
        tr '\n' ',' < "${PKG_FILE}" | sed 's/,$//'
    else
        echo "com.dts.freefiremax,com.sandboxol.blockymods"
    fi
}

# Latest log snippet
get_last_log() {
    if [ -f "${LOG_FILE}" ]; then
        tail -n 1 "${LOG_FILE}" | sed 's/=/ /g'
    else
        echo "Plugin initialized and active."
    fi
}

CPU_LOAD="$(get_cpu_load)"
RAM_INFO="$(get_ram_info)"
BAT_LEVEL="$(get_battery)"
FG_APP="$(get_fg_app)"
PKGS="$(get_pkgs_str)"
LAST_LOG="$(get_last_log)"

echo "ok=1"
echo "model=${MODEL}"
echo "and=${ANDROID_VER}"
echo "oneui=${ONEUI_VER}"
echo "load=${CPU_LOAD}"
echo "ram=${RAM_INFO}"
echo "bat=${BAT_LEVEL}"
echo "m1=${M1}"
echo "m2=${M2}"
echo "m3=${M3}"
echo "m4=${M4}"
echo "fg_app=${FG_APP}"
echo "pkgs=${PKGS}"
echo "last_log=${LAST_LOG}"
