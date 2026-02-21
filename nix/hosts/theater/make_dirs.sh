#!/bin/sh
sudo mkdir -p /data/{torrents/{movies,tv,books,audiobooks,completed,incomplete},media/{movies,tv,books,audiobooks}}
sudo mkdir -p /docker/appdata/{gluetun,qbittorrent,prowlarr,radarr,sonarr,flaresolverr,jellyfin,jellyseerr,audiobookshelf,calibre,calibre-web}
sudo chown -R 1000:1000 /data
sudo chown -R 1000:1000 /docker/appdata
sudo chmod -R 775 /data
sudo chmod -R 775 /docker/appdata
