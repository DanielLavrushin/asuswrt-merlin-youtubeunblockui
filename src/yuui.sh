#!/bin/sh

export PATH=/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin
source /usr/sbin/helper.sh
VERSION="0.0"
ADDON_TAG="yuui"
ADDON_TAG_UPPER="YUUI"
ADDON_NAME="YoutubeUnblock UI"
ADDON_TITLE="Youtube Unblock"

LOCKFILE=/tmp/$ADDON_TAG.lock
DIR_WEB="/www/user/$ADDON_TAG"
DIR_SHARE="/opt/share/$ADDON_TAG"
DIR_JFFS_ADDONS="/jffs/addons/$ADDON_TAG"

UI_RESPONSE_FILE="/tmp/"$ADDON_TAG"_response.json"

# Color Codes
CERR='\033[0;31m'
CSUC='\033[0;32m'
CWARN='\033[0;33m'
CINFO='\033[0;36m'
CRESET='\033[0m'

printlog() {
    if [ "$1" = "true" ]; then
        logger -t "$ADDON_TAG_UPPER" "$2"
    fi
    printf "${CINFO}${3}%s${CRESET}\\n" "$2"
}

install() {
    printlog true "Start installing $ADDON_TITLE..." $CINFO

    mkdir -p "$DIR_WEB"

    package=$(define_package)

    printlog true "Detected architecture package: $package" $CINFO
    download_latest $package

    if [ -f "/tmp/yutubeunblock.ipk" ]; then
        opkg install "/tmp/yutubeunblock.ipk" || {
            printlog true "Failed to install $ADDON_TAG_UPPER." $CERR
            exit 1
        }
    else
        printlog true "Package not found." $CERR
        exit 1
    fi

    # Add or update firewall-start
    printlog true "Ensuring /jffs/scripts/firewall-start contains required entry."
    if [ ! -f /jffs/scripts/firewall-start ]; then
        echo "#!/bin/sh" >/jffs/scripts/firewall-start
    else
        printlog true "Removing existing #$ADDON_TAG entries from /jffs/scripts/firewall-start."
        sed -i /#$ADDON_TAG/d /jffs/scripts/firewall-start
    fi
    chmod +x /jffs/scripts/firewall-start
    echo "/jffs/scripts/$ADDON_TAG service_event startup & #$ADDON_TAG" >>/jffs/scripts/firewall-start
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

    remount_ui

    restart

    printlog true "$ADDON_TITLE installed successfully." $CSUC
}

start() {
    printlog true "Starting $ADDON_TITLE..." $CINFO
    /opt/etc/init.d/*youtubeUnblock restart
}

stop() {
    printlog true "Stopping $ADDON_TITLE..." $CINFO
    killall youtubeUnblock
    sleep 1
}

restart() {
    stop
    start
}

download_latest() {
    pkg_pattern=$1
    api_url="https://api.github.com/repos/Waujito/youtubeUnblock/releases/latest"
    response=$(curl -s "$api_url")
    asset_url=""
    for name in $(echo "$response" | jq -r '.assets[].name'); do
        echo "$name" | grep -E "$pkg_pattern" >/dev/null 2>&1 && {
            asset_url=$(echo "$response" | jq -r --arg name "$name" '.assets[] | select(.name==$name) | .browser_download_url' | head -n 1)
            break
        }
    done
    if [ -z "$asset_url" ]; then
        printlog true "Artifact not found for pattern: $pkg_pattern" $CERR
        return 1
    fi
    printlog true "Downloading package from $asset_url" $CINFO
    curl -L -o "/tmp/yutubeunblock.ipk" "$asset_url"
}

define_package() {
    arch=$(uname -m)
    kernel=$(uname -r)
    kernel_major=${kernel%%.*}

    case "$arch" in
    aarch64)
        pattern="youtubeUnblock-.*-entware-aarch64-.*\\.ipk"
        ;;
    arm*)
        if [ "$kernel_major" -ge 3 ]; then
            pattern="youtubeUnblock-.*-entware-armv7-3\\.2\\.ipk"
        else
            pattern="youtubeUnblock-.*-entware-armv7-2\\.6\\.ipk"
        fi
        ;;
    mipsel)
        pattern="youtubeUnblock-.*-entware-mipsel-3\\.4\\.ipk"
        ;;
    mips)
        pattern="youtubeUnblock-.*-entware-mips-3\\.4\\.ipk"
        ;;
    x86_64)
        pattern="youtubeUnblock-.*-entware-x64-3\\.2\\.ipk"
        ;;
    i386 | i686)
        pattern="youtubeUnblock-.*-entware-x86-2\\.6\\.ipk"
        ;;
    *)
        echo "Unsupported architecture: $arch" >&2
        return 1
        ;;
    esac

    echo "$pattern"
}

uninstall() {
    printlog true "Uninstalling $ADDON_TAG_UPPER..." $CINFO

}

get_webui_page() {
    USER_PAGE="none"
    max_user_page=0
    used_pages=""

    for page in /www/user/user*.asp; do
        if [ -f "$page" ]; then
            if grep -q "page:$ADDON_TAG" "$page"; then
                USER_PAGE=$(basename "$page")
                printlog true "Found existing $ADDON_TAG_UPPER page: $USER_PAGE" $CSUC
                return
            fi

            user_number=$(echo "$page" | sed -E 's/.*user([0-9]+)\.asp$/\1/')
            used_pages="$used_pages $user_number"

            if [ "$user_number" -gt "$max_user_page" ]; then
                max_user_page="$user_number"
            fi
        fi
    done

    if [ "$USER_PAGE" != "none" ]; then
        printlog true "Found existing $ADDON_TAG_UPPER page: $USER_PAGE" $CSUC
        return
    fi

    if [ "$1" = "true" ]; then
        i=1
        while true; do
            if ! echo "$used_pages" | grep -qw "$i"; then
                USER_PAGE="user$i.asp"
                printlog true "Assigning new $ADDON_TAG_UPPER page: $USER_PAGE" $CSUC
                return
            fi
            i=$((i + 1))
        done
    fi
}

mount_ui() {

    FD=386
    eval exec "$FD>$LOCKFILE"
    flock -x "$FD"

    nvram get rc_support | grep -q am_addons
    if [ $? != 0 ]; then
        printlog true "This firmware does not support addons!" $CERR
        exit 5
    fi

    get_webui_page true

    if [ "$USER_PAGE" = "none" ]; then
        printlog true "Unable to install $ADDON_TAG_UPPER" $CERR
        exit 5
    fi

    printlog true "Mounting $ADDON_TAG_UPPER as $USER_PAGE"

    if [ ! -d $DIR_WEB ]; then
        mkdir -p "$DIR_WEB"
    fi

    if [ ! -d "$DIR_SHARE/data" ]; then
        mkdir -p "$DIR_SHARE/data"
    fi

    ln -s -f /jffs/addons/$ADDON_TAG/index.asp /www/user/$USER_PAGE
    ln -s -f /jffs/addons/$ADDON_TAG/app.js $DIR_WEB/app.js
    ln -s -f $UI_RESPONSE_FILE $DIR_WEB/response.json
    ln -s -f /jffs/addons/$ADDON_TAG/assets/ $DIR_WEB/assets

    echo "$ADDON_TAG_UPPER" >"/www/user/$(echo $USER_PAGE | cut -f1 -d'.').title"

    if [ ! -f /tmp/menuTree.js ]; then
        cp /www/require/modules/menuTree.js /tmp/
        mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
    fi

    sed -i '/index: "menu_VPN"/,/index:/ {
  /url:\s*"NULL",\s*tabName:\s*"__INHERIT__"/ i \
    { url: "'"$USER_PAGE"'", tabName: "'"$ADDON_TITLE"'" },
}' /tmp/menuTree.js

    umount /www/require/modules/menuTree.js && mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js

    flock -u "$FD"
    printlog true "$ADDON_TAG_UPPER mounted successfully as $USER_PAGE" $CSUC
}

unmount_ui() {
    FD=386
    eval exec "$FD>$LOCKFILE"
    flock -x "$FD"

    nvram get rc_support | grep -q am_addons
    if [ $? != 0 ]; then
        printlog true "This firmware does not support addons!" $CERR
        exit 5
    fi

    get_webui_page

    base_user_page="${USER_PAGE%.asp}"

    if [ -z "$USER_PAGE" ] || [ "$USER_PAGE" = "none" ]; then
        printlog true "No $ADDON_TAG_UPPER page found to unmount. Continuing to clean up..." $CWARN
    else
        printlog true "Unmounting $ADDON_TAG_UPPER $USER_PAGE"
        rm -fr /www/user/$USER_PAGE
        rm -fr /www/user/$base_user_page.title
    fi

    if [ ! -f /tmp/menuTree.js ]; then
        printlog true "menuTree.js not found, skipping unmount." $CWARN
    else
        printlog true "Removing any X-RAY menu entry from menuTree.js."

        grep -v "tabName: \"$ADDON_TITLE\"" /tmp/menuTree.js >/tmp/menuTree_temp.js
        mv /tmp/menuTree_temp.js /tmp/menuTree.js

        umount /www/require/modules/menuTree.js
        mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
    fi

    rm -rf $DIR_WEB

    flock -u "$FD"

    printlog true "Unmount completed." $CSUC
}

remount_ui() {
    unmount_ui
    mount_ui
}

am_settings_del() {
    local key="$1"
    sed -i "/$key/d" /jffs/addons/custom_settings.txt
}

reconstruct_payload() {
    FD=386
    eval exec "$FD>$LOCKFILE"

    if ! flock -x "$FD"; then
        return 1
    fi

    local idx=0
    local chunk
    local payload=""
    while :; do
        chunk=$(am_settings_get yuui_payload$idx)
        if [ -z "$chunk" ]; then
            break
        fi
        payload="$payload$chunk"
        idx=$((idx + 1))
    done

    cleanup_payloads

    echo "$payload"

    flock -u "$FD"
}

cleanup_payloads() {
    sed -i '/^yuui_payload/d' /jffs/addons/custom_settings.txt
}

ensure_ui_response_file() {
    if [ ! -f "$UI_RESPONSE_FILE" ]; then
        printlog true "Creating $ADDON_TITLE response file: $UI_RESPONSE_FILE"
        echo '{"yuui":{}}' >"$UI_RESPONSE_FILE"
        chmod 600 "$UI_RESPONSE_FILE"
    fi

    if [ -f "$UI_RESPONSE_FILE" ]; then
        UI_RESPONSE=$(cat "$UI_RESPONSE_FILE")
    else
        UI_RESPONSE="{}"
    fi

}

update_loading_progress() {
    local message=$1
    local progress=$2

    ensure_ui_response_file

    if [ -n "$progress" ]; then

        UI_RESPONSE=$(echo "$UI_RESPONSE" | jq --argjson progress "$progress" --arg message "$message" '
            .loading.message = $message |
            .loading.progress = $progress
        ')
    else
        UI_RESPONSE=$(echo "$UI_RESPONSE" | jq --arg message "$message" '
            .loading.message = $message
        ')
    fi

    echo "$UI_RESPONSE" >"$UI_RESPONSE_FILE"

    if [ "$progress" = "100" ]; then
        /jffs/scripts/$ADDON_TAG service_event cleanloadingprogress &
    fi

}

remove_loading_progress() {
    printlog true "Removing loading progress..."
    sleep 1
    ensure_ui_response_file

    UI_RESPONSE=$(echo "$UI_RESPONSE" | jq '
            del(.loading)
        ')

    echo "$UI_RESPONSE" >"$UI_RESPONSE_FILE"
    exit 0
}

packages_installed() {
    update_loading_progress "Getting installed packages..." 0
    printlog true "Getting installed packages..."
    ensure_ui_response_file

    UI_RESPONSE=$(echo "$UI_RESPONSE" | jq '.'"$ADDON_TAG"'.installed = []')

    while IFS= read -r line; do
        pkg=$(echo "$line" | awk -F" - " '{print $1}')
        version=$(echo "$line" | awk -F" - " '{print $2}')
        UI_RESPONSE=$(echo "$UI_RESPONSE" | jq --arg pkg "$pkg" --arg ver "$version" \
            '.'"$ADDON_TAG"'.installed += [{ "name": $pkg, "version": $ver }]')
    done <<EOF
$(opkg list-installed)
EOF

    echo "$UI_RESPONSE" >"$UI_RESPONSE_FILE"

    update_loading_progress "Installed packages retrieved." 100
    printlog true "Installed packages retrieved." $CSUC
}

case "$1" in
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
