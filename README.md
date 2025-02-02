![GitHub Release](https://img.shields.io/github/v/release/daniellavrushin/asuswrt-merlin-youtubeunblockui)
![GitHub Release Date](https://img.shields.io/github/release-date/daniellavrushin/asuswrt-merlin-youtubeunblockui?logoColor=violet)
![GitHub commits since latest release](https://img.shields.io/github/commits-since/daniellavrushin/asuswrt-merlin-youtubeunblockui/latest)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/21e0521401c44b22b5b4e6e322554ccc)](https://app.codacy.com/gh/DanielLavrushin/asuswrt-merlin-youtubeunblockui/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
![GitHub Downloads (specific asset, latest release)](https://img.shields.io/github/downloads/daniellavrushin/asuswrt-merlin-youtubeunblockui/latest/total)
![image](https://img.shields.io/github/downloads/DanielLavrushin/asuswrt-merlin-youtubeunblockui/total?label=total%20downloads)

# ASUS YoutubeUnblock UI
This project simplifies the process of installing and controlling [Waujito's YoutubeUnblock](https://github.com/Waujito/youtubeUnblock) on ASUS routers running [MerlinWRT](https://github.com/RMerl) firmware.

![image](https://github.com/user-attachments/assets/c193be12-6a73-4860-bcaf-06b209461ff4)

## Install

```bash
wget -O /tmp/asuswrt-merlin-yuui.tar.gz https://github.com/DanielLavrushin/asuswrt-merlin-youtubeunblockui/releases/latest/download/asuswrt-merlin-yuui.tar.gz && rm -rf /jffs/addons/yuui && tar -xzf /tmp/asuswrt-merlin-yuui.tar.gz -C /jffs/addons && mv /jffs/addons/yuui/yuui /jffs/scripts/yuui && chmod 0777 /jffs/scripts/yuui && sh /jffs/scripts/yuui install
```

## Usage

After installation, log out and log back into your router's interface. A new sub-menu called Youtube Unblock should appear under the Firewall menu. Simply click the Youtube Unblock button and enjoy!
