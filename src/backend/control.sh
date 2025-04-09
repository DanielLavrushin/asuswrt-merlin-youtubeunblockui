#!/bin/sh
# shellcheck disable=SC2034  # codacy:Unused variables

start() {
    printlog true "Starting $ADDON_TITLE..." $CINFO
    /opt/etc/init.d/*youtubeUnblock restart
    am_settings_set yuui_startup y
    load_ui_respon
    printlog true "$ADDON_TITLE started." $CSUC
}

stop() {
    printlog true "Stopping $ADDON_TITLE..." $CINFO
    killall youtubeUnblock
    am_settings_set yuui_startup n
    sleep 1
    printlog true "$ADDON_TITLE stopped." $CSUC
}

restart() {
    stop
    start
}

startup() {
    printlog true "Starting $ADDON_TITLE on boot..." $CINFO
    if [ "$(am_settings_get yuui_startup)" = "y" ]; then
        (sleep 60 && /jffs/scripts/yuui start) &
    else
        printlog true "$ADDON_TITLE is not set to start on boot." $CWARN
    fi
}
