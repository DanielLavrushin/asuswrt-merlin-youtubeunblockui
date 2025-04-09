#!/bin/sh
# shellcheck disable=SC2034  # codacy:Unused variables

mount_ui() {

    check_lock

    nvram get rc_support | grep -q am_addons
    if [ $? != 0 ]; then
        printlog true "This firmware does not support addons!" $CERR
        exit 5
    fi

    get_webui_page true

    if [ "$ADDON_USER_PAGE" = "none" ]; then
        printlog true "Unable to install $ADDON_TITLE" $CERR
        exit 5
    fi

    printlog true "Mounting $ADDON_TITLE as $ADDON_USER_PAGE"

    if [ ! -d $ADDON_WEB_DIR ]; then
        mkdir -p "$ADDON_WEB_DIR"
    fi

    if [ ! -d "$ADDON_SHARE_DIR" ]; then
        mkdir -p "$ADDON_SHARE_DIR"
    fi

    if [ ! -d "$ADDON_SHARE_DIR/data" ]; then
        mkdir -p "$ADDON_SHARE_DIR/data"
    fi

    ln -s -f /jffs/addons/$ADDON_TAG/index.asp /www/user/$ADDON_USER_PAGE
    ln -s -f /jffs/addons/$ADDON_TAG/app.js $ADDON_WEB_DIR/app.js
    ln -s -f /jffs/addons/$ADDON_TAG/assets/ $ADDON_WEB_DIR/assets

    echo "$ADDON_TAG" >"/www/user/$(echo $ADDON_USER_PAGE | cut -f1 -d'.').title"

    if [ ! -f /tmp/menuTree.js ]; then
        cp /www/require/modules/menuTree.js /tmp/
        mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
    fi

    sed -i '/index: "menu_Firewall"/,/index:/ {
  /url:\s*"NULL",\s*tabName:\s*"__INHERIT__"/ i \
    { url: "'"$ADDON_USER_PAGE"'", tabName: "'"$ADDON_TITLE"'" },
}' /tmp/menuTree.js

    umount /www/require/modules/menuTree.js && mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
    load_ui_response
    clear_lock

    printlog true "$ADDON_TITLE mounted successfully as $ADDON_USER_PAGE" $CSUC
}

unmount_ui() {

    check_lock

    get_webui_page

    printlog true "Unmounting $ADDON_TITLE from $ADDON_USER_PAGE"
    base_user_page="${ADDON_USER_PAGE%.asp}"

    if [ -z "$ADDON_USER_PAGE" ] || [ "$ADDON_USER_PAGE" = "none" ]; then
        printlog true "No $ADDON_TAG_UPPER page found to unmount. Continuing to clean up..." $CWARN
    else
        rm -fr /www/user/$ADDON_USER_PAGE
        rm -fr /www/user/$base_user_page.title
    fi

    if [ ! -f /tmp/menuTree.js ]; then
        printlog true "menuTree.js not found, skipping unmount." $CWARN
    else
        printlog true "Removing any $ADDON_TITLE menu entry from menuTree.js."

        grep -v "tabName: \"$ADDON_TITLE\"" /tmp/menuTree.js >/tmp/menuTree_temp.js
        mv /tmp/menuTree_temp.js /tmp/menuTree.js

        umount /www/require/modules/menuTree.js
        mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
    fi

    clear_lock

    printlog true "Unmount completed." $CSUC
}

remount_ui() {
    unmount_ui
    sleep 1
    mount_ui
}
