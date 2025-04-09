#!/bin/sh
# shellcheck disable=SC2034  # codacy:Unused variables

update() {

    local specific_version=${1:-"latest"}

    update_loading_progress "Updating $ADDON_TITLE : $specific_version..."
    printlog true "Updating $ADDON_TITLE : $specific_version..."

    local url="https://github.com/daniellavrushin/asuswrt-merlin-youtubeunblockui/releases/latest/download/asuswrt-merlin-yuui.tar.gz"
    if [ ! $specific_version = "latest" ]; then
        local url=$(github_proxy_url "https://github.com/daniellavrushin/asuswrt-merlin-youtubeunblockui/releases/download/v$specific_version/asuswrt-merlin-yuui.tar.gz")
    fi

    local temp_file="/tmp/asuswrt-merlin-yuui.tar.gz"

    printlog true "Downloading the latest version..."
    update_loading_progress "Downloading the latest version..."

    if wget -q --show-progress -O "$temp_file" "$url"; then
        printlog true "Download completed successfully."
    else
        printlog true "Failed to download the latest version. Exiting."
        return 1
    fi

    printlog true "Running the installation..."
    update_loading_progress "Running the installation..."

    if sh "$ADDON_SCRIPT" install; then
        printlog true "Installation completed successfully." $CSUC
    else
        printlog true "Installation failed. Exiting." $CERR
        return 1
    fi

    printlog true "Update process completed!" $CSUC
    update_loading_progress "Update process completed!" 100
}
