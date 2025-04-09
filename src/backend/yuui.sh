#!/bin/sh
# shellcheck disable=SC2034  # codacy:Unused variables

import ./_globals.sh
import ./_helper.sh

import ./lock.sh
import ./mount.sh
import ./control.sh
import ./update.sh
import ./package.sh
import ./install.sh

case "$1" in
test)
    install
    uninstall
    ;;
install)
    install
    ;;
uninstall)
    uninstall
    ;;
start)
    start
    ;;
stop)
    stop
    ;;
restart)
    restart
    ;;
startup)
    startup
    ;;
update)
    update $2
    ;;
mount_ui)
    mount_ui
    ;;
unmount_ui)
    unmount_ui
    ;;
remount_ui)
    remount_ui $2
    ;;
service_event)
    case "$2" in
    update)
        update
        ;;
    service)
        case "$3" in
        start)
            start
            ;;
        stop)
            stop
            ;;
        esac
        ;;
    cleanloadingprogress)
        remove_loading_progress
        ;;
    esac
    exit 0
    ;;
*)
    echo "Usage: $0 {install|uninstall|start|stop|restart|update|mount_ui|unmount_ui|remount_ui}"
    exit 1
    ;;
esac

exit 0
