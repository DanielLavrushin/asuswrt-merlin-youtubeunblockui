#!/bin/sh
# shellcheck disable=SC2034  # codacy:Unused variables

update() {

    local specific_version=${1:-"latest"}

    update_loading_progress "Updating $ADDON_TITLE : $specific_version..."
    printlog true "Updating $ADDON_TITLE : $specific_version..."

    local url="https://github.com/daniellavrushin/asuswrt-merlin-youtubeunblockui/releases/latest/download/asuswrt-merlin-yuui.tar.gz"
    if [ ! $specific_version = "latest" ]; then
        local url="https://github.com/daniellavrushin/asuswrt-merlin-youtubeunblockui/releases/download/v$specific_version/asuswrt-merlin-yuui.tar.gz"
    fi

    local temp_file="/tmp/asuswrt-merlin-yuui.tar.gz"
    local jffs_addons_path="/jffs/addons"

    printlog true "Downloading the $specific_version version..."
    update_loading_progress "Downloading the $specific_version version..."

    if wget -q --show-progress -O "$temp_file" "$url"; then
        printlog true "Download completed successfully."
    else
        printlog true "Failed to download the $specific_version version. Exiting." $CERR
        return 1
    fi

    printlog true "Cleaning up existing installation..."
    if rm -rf "$ADDON_JFFS_ADN_DIR"; then
        printlog true "Old installation removed."
    else
        printlog true "Failed to remove the old installation. Exiting." $CERR
        return 1
    fi

    printlog true "Extracting the package..."
    update_loading_progress "Extracting the package..."
    if tar -xzf "$temp_file" -C "$jffs_addons_path"; then
        printlog true "Extraction completed."

        mv /jffs/addons/yuui/yuui "$ADDON_SCRIPT"
        chmod 0777 "$ADDON_SCRIPT"

    else
        printlog true "Failed to extract the package. Exiting." $CERR
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
