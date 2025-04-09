#!/bin/sh
# shellcheck disable=SC2034  # codacy:Unused variables

export PATH="/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin"

source /usr/sbin/helper.sh

ADDON_TAG="yuui"
ADDON_TAG_UPPER="YUUI"
ADDON_TITLE="YoutubeUnblock UI"

VERSION="1.0.0"

ADDON_WEB_DIR="/www/user/$ADDON_TAG"

ADDON_SCRIPT="/jffs/scripts/$ADDON_TAG"
ADDON_SHARE_DIR="/opt/share/$ADDON_TAG"
ADDON_JFFS_ADN_DIR="/jffs/addons/$ADDON_TAG"
ADDON_LOGS_DIR="$ADDON_SHARE_DIR/logs"

UI_RESPONSE_FILE="$ADDON_WEB_DIR/response.json"
