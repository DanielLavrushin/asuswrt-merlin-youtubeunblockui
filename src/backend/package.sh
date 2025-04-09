#!/bin/sh
# shellcheck disable=SC2034  # codacy:Unused variables

define_package() {
    local arch=$(uname -m)
    local kernel=$(uname -r)
    local kernel_major=${kernel%%.*}

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

download_latest() {
    local pkg_pattern=$1
    local api_url="https://api.github.com/repos/Waujito/youtubeUnblock/releases/latest"
    local response=$(curl -s "$api_url")
    local asset_url=""

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
    wget -q --show-progress -O "/tmp/yuotubeunblock.ipk" "$asset_url" || {
        printlog true "Failed to download package." $CERR
        return 1
    }
}
