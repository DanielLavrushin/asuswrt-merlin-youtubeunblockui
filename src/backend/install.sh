#!/bin/sh
# shellcheck disable=SC2034  # codacy:Unused variables

install() {
    printlog true "Start installing $ADDON_TITLE..." $CINFO

    opkg install jq
    opkg install curl
    opkg install sed
    opkg install flock

    am_settings_set yuui_version $VERSION

    mkdir -p "$ADDON_WEB_DIR"

    package=$(define_package)

    printlog true "Detected architecture package: $package" $CINFO
    download_latest $package

    if [ -f "/tmp/yuotubeunblock.ipk" ]; then
        opkg install "/tmp/yuotubeunblock.ipk" || {
            printlog true "Failed to install $ADDON_TITLE." $CERR
            exit 1
        }
    else
        printlog true "Package not found." $CERR
        exit 1
    fi

    # Add or update post-mount
    printlog true "Ensuring /jffs/scripts/post-mount contains required entry."
    mkdir -p /jffs/scripts
    if [ ! -f /jffs/scripts/post-mount ]; then
        echo "#!/bin/sh" >/jffs/scripts/post-mount
    else
        printlog true "Removing existing #$ADDON_TAG entries from /jffs/scripts/post-mount."
        sed -i /#$ADDON_TAG/d /jffs/scripts/post-mount
    fi
    chmod +x /jffs/scripts/post-mount
    echo "/jffs/scripts/$ADDON_TAG remount_ui"' "$@" & #'"$ADDON_TAG" >>/jffs/scripts/post-mount
    printlog true "Updated /jffs/scripts/post-mount with $ADDON_TAG entry." $CSUC

    # Add or update firewall-start
    printlog true "Ensuring /jffs/scripts/firewall-start contains required entry."
    if [ ! -f /jffs/scripts/firewall-start ]; then
        echo "#!/bin/sh" >/jffs/scripts/firewall-start
    else
        printlog true "Removing existing #$ADDON_TAG entries from /jffs/scripts/firewall-start."
        sed -i /#$ADDON_TAG/d /jffs/scripts/firewall-start
    fi
    chmod +x /jffs/scripts/firewall-start
    echo "/jffs/scripts/$ADDON_TAG startup & #$ADDON_TAG" >>/jffs/scripts/firewall-start
    printlog true "Updated /jffs/scripts/firewall-start with $ADDON_TAG entry." $CSUC

    # Add or update service-event
    printlog true "Ensuring /jffs/scripts/service-event contains required entry."
    if [ ! -f /jffs/scripts/service-event ]; then
        echo "#!/bin/sh" >/jffs/scripts/service-event
    else
        printlog true "Removing existing #$ADDON_TAG entries from /jffs/scripts/service-event."
        sed -i /#$ADDON_TAG/d /jffs/scripts/service-event
    fi
    chmod +x /jffs/scripts/service-event
    echo "echo \"\$2\" | grep -q \"^$ADDON_TAG\" && /jffs/scripts/$ADDON_TAG service_event \$(echo \"\$2\" | cut -d'_' -f2- | tr '_' ' ') & #$ADDON_TAG" >>/jffs/scripts/service-event
    printlog true "Updated /jffs/scripts/service-event with $ADDON_TITLE entry." $CSUC

    ln -s -f "$ADDON_SCRIPT" "/opt/bin/$ADDON_TAG" || printlog true "Failed to create symlink for $ADDON_TAG." $CERR

    load_ui_response

    remount_ui

    restart

    printlog true "$ADDON_TITLE installed successfully." $CSUC
}

uninstall() {
    printlog true "Uninstalling $ADDON_TITLE..." $CINFO

    unmount_ui

    rm -rf /www/user/$ADDON_TAG /jffs/addons/$ADDON_TAG /tmp/$ADDON_TAG*.json

    # clean up services-start
    printlog true "Removing existing #$ADDON_TAG entries from /jffs/scripts/services-start."
    sed -i /#$ADDON_TAG/d /jffs/scripts/services-start

    # clean up nat-start
    printlog true "Removing existing #$ADDON_TAG entries from /jffs/scripts/nat-start."
    sed -i /#$ADDON_TAG/d /jffs/scripts/nat-start

    # clean up post-mount
    printlog true "Removing existing #$ADDON_TAG entries from /jffs/scripts/post-mount."
    sed -i /#$ADDON_TAG/d /jffs/scripts/post-mount

    # clean up service-event
    printlog true "Removing existing #$ADDON_TAG entries from /jffs/scripts/service-event."
    sed -i /#$ADDON_TAG/d /jffs/scripts/service-event

    # clean up firewall-start
    printlog true "Removing existing #$ADDON_TAG entries from /jffs/scripts/firewall-start."
    sed -i /#$ADDON_TAG/d /jffs/scripts/firewall-start

    printlog true "Unmounting $ADDON_TITLE..." $CINFO

    if [ -f "$PIDFILE" ]; then
        printlog true "Stopping $ADDON_TITLE service..."
        stop
        rm -f $PIDFILE
        printlog true "$ADDON_TITLE service stopped." $CSUC
    else
        printlog true "$ADDON_TITLE service is not running." $CWARN
    fi

    # Remove  custom settings
    printlog true "Removing $ADDON_TITLE custom settings..."

    grep '^yuui_' /jffs/addons/custom_settings.txt | while IFS='=' read -r var_name _; do
        [ -n "$var_name" ] && am_settings_del "$var_name"
    done

    rm -f /jffs/scripts/$ADDON_TAG
    rm -rf "/opt/bin/$ADDON_TAG" || printlog true "Failed to remove symlink for $ADDON_TAG." $CERR

    opkg remove youtubeUnblockEntware --force-remove
}
