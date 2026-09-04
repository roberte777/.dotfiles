#!/bin/sh
sudo mkdir -p /mnt/storage/{torrents/{movies,tv,books,audiobooks,shelfarr,completed,incomplete},usenet/{complete/{movies,tv,books,audiobooks},incomplete},media/{movies,tv,books,audiobooks}}
sudo mkdir -p /docker/appdata/{gluetun,qbittorrent,qbittorrent-mam,mousehole,prowlarr,radarr,sonarr,flaresolverr,jellyfin,plex,seerr,seerr-plex,bazarr,kasm,audiobookshelf,calibre,calibre-web,sabnzbd,shelfarr,profilarr,homarr,portainer,vaultwarden,tautulli,uptime-kuma,ntfy/{cache,etc},omnibus/{config,cache}}

# Observability. These dirs are only half the story -- the services also need
# config files, which live in observability/ in this repo. After running this:
#
#   cp -r observability/* /docker/appdata/
#   cp observability/grafana/provisioning/alerting/contact-points.yaml.example \
#      /docker/appdata/grafana/provisioning/alerting/contact-points.yaml
#   # then put NTFY_TOPIC into that file
#
# Loki, Alloy and Prometheus do not start at all without their config, and
# Grafana comes up with no datasources or alert rules -- which looks like a
# working install until you notice everything is empty.
#
# Dashboard JSON is NOT in the repo by choice; rebuild those in the UI. Only
# the datasources and alert rules are worth restoring automatically.
#
# grafana/data/dashboards sits inside the /var/lib/grafana mount deliberately,
# so provisioned dashboards need no extra compose volume.
sudo mkdir -p /docker/appdata/{loki/data,alloy/data,prometheus/data}
sudo mkdir -p /docker/appdata/grafana/{data/dashboards,provisioning/{datasources,dashboards,alerting}}

sudo chown -R 1000:1000 /mnt/storage
sudo chown -R 1000:1000 /docker/appdata
sudo chmod -R 775 /mnt/storage
sudo chmod -R 775 /docker/appdata

# node-exporter's textfile collector. Lives outside /docker/appdata because the
# smart-textfile systemd timer writes it as root on the host, not from a
# container. node-exporter mounts it read-only.
sudo mkdir -p /var/lib/node-exporter/textfile
sudo chmod 755 /var/lib/node-exporter/textfile
