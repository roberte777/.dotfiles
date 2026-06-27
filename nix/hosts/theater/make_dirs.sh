#!/bin/sh
sudo mkdir -p /mnt/storage/{torrents/{movies,tv,books,audiobooks,shelfarr,completed,incomplete},usenet/{complete/{movies,tv,books,audiobooks},incomplete},media/{movies,tv,books,audiobooks}}
sudo mkdir -p /docker/appdata/{gluetun,qbittorrent,prowlarr,radarr,sonarr,flaresolverr,jellyfin,seerr,audiobookshelf,calibre,calibre-web,sabnzbd,shelfarr,profilarr,homarr}
sudo chown -R 1000:1000 /mnt/storage
sudo chown -R 1000:1000 /docker/appdata
sudo chmod -R 775 /mnt/storage
sudo chmod -R 775 /docker/appdata
