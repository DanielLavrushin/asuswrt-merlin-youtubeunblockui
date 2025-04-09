#!/bin/sh
# shellcheck disable=SC2034  # codacy:Unused variables

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

get_proc() {
    local proc_name="$1"
    echo $(/bin/pidof "$proc_name" 2>/dev/null)
}

get_proc_uptime() {
    local uptime_s=$(cut -d. -f1 /proc/uptime)
    local pid=$(pidof "$1")

    local localstart_time_jiffies=$(awk '{print $22}' /proc/$pid/stat)

    local jiffies_per_sec=100

    local process_start_s=$((localstart_time_jiffies / jiffies_per_sec))

    local proc_uptime=$((uptime_s - process_start_s))
    echo $proc_uptime
}

get_webui_page() {
    ADDON_USER_PAGE="none"
    local max_user_page=0
    local used_pages=""

    for page in /www/user/user*.asp; do
        if [ -f "$page" ]; then
            if grep -q "page:$ADDON_TAG" "$page"; then
                ADDON_USER_PAGE=$(basename "$page")
                printlog true "Found existing $ADDON_TAG_UPPER page: $ADDON_USER_PAGE" $CSUC
                return
            fi

            user_number=$(echo "$page" | sed -E 's/.*user([0-9]+)\.asp$/\1/')
            used_pages="$used_pages $user_number"

            if [ "$user_number" -gt "$max_user_page" ]; then
                max_user_page="$user_number"
            fi
        fi
    done

    if [ "$ADDON_USER_PAGE" != "none" ]; then
        printlog true "Found existing $ADDON_TAG_UPPER page: $ADDON_USER_PAGE" $CSUC
        return
    fi

    if [ "$1" = "true" ]; then
        i=1
        while true; do
            if ! echo "$used_pages" | grep -qw "$i"; then
                ADDON_USER_PAGE="user$i.asp"
                printlog true "Assigning new $ADDON_TAG_UPPER page: $ADDON_USER_PAGE" $CSUC
                return
            fi
            i=$((i + 1))
        done
    fi
}

am_settings_del() {
    local key="$1"
    sed -i "/$key/d" /jffs/addons/custom_settings.txt
}

reconstruct_payload() {

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

    cleanup_payload

    echo "$payload"

}

cleanup_payload() {
    # clean up all payload chunks from the custom settings
    sed -i '/^yuui_payload/d' /jffs/addons/custom_settings.txt
}

load_ui_response() {

    if [ ! -f "$UI_RESPONSE_FILE" ]; then
        printlog true "Creating $ADDON_TITLE response file: $UI_RESPONSE_FILE" "$CSUC"
        echo '{}' >"$UI_RESPONSE_FILE"
        chmod 600 "$UI_RESPONSE_FILE"
    fi

    UI_RESPONSE=$(cat "$UI_RESPONSE_FILE")
    if [ "$UI_RESPONSE" = "" ]; then
        printlog true "UI response file is empty. Initializing with empty JSON." "$CWARN"
        UI_RESPONSE="{}"
    fi
}

save_ui_response() {

    if ! echo "$UI_RESPONSE" >"$UI_RESPONSE_FILE"; then
        printlog true "Failed to save UI response to $UI_RESPONSE_FILE" "$CERR"
        clear_lock
        return 1
    fi

}

update_loading_progress() {
    local message=$1
    local progress=$2

    if [ ! -d "$ADDON_WEB_DIR" ]; then
        return
    fi

    load_ui_response

    local json_content
    if [ -f "$UI_RESPONSE_FILE" ]; then
        json_content=$(cat "$UI_RESPONSE_FILE")
    else
        json_content="{}"
    fi

    if [ -n "$progress" ]; then
        json_content=$(echo "$json_content" | jq --argjson progress "$progress" --arg message "$message" '
            .loading.message = $message |
            .loading.progress = $progress
        ')
    else
        json_content=$(echo "$json_content" | jq --arg message "$message" '
            .loading.message = $message
        ')
    fi

    echo "$json_content" >"$UI_RESPONSE_FILE"

    if [ "$progress" = "100" ]; then
        $ADDON_SCRIPT service_event cleanloadingprogress &
    fi

}

remove_loading_progress() {

    printlog true "Removing loading progress..."
    if [ ! -d "$ADDON_WEB_DIR" ]; then
        return
    fi

    sleep 1
    load_ui_response

    local json_content=$(cat "$UI_RESPONSE_FILE")

    json_content=$(echo "$json_content" | jq '
            del(.loading)
        ')

    echo "$json_content" >"$UI_RESPONSE_FILE"
}

fixme() {
    printlog true "Attempting to fix $ADDON_TITLE issues..."

    printlog true "Removing $ADDON_TITLE broken payload settings..."

    sed -i '/^yuui_payload/d' /jffs/addons/custom_settings.txt

    printlog true "Removing file $UI_RESPONSE_FILE..."
    rm -f $UI_RESPONSE_FILE

    printlog true "Done with fixme function." "$CSUC"
}
