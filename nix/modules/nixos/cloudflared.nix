{...}: let
  # === Fill these in ===
  # Tunnel UUID from `cloudflared tunnel create theater`
  tunnelId = "0f176346-8e25-4b26-82ff-89b2b94b8fcf";
  # Your domain
  domain = "wildmanwilkes.org";

  # Credentials JSON written by `cloudflared tunnel create`.
  # Copy ~/.cloudflared/<UUID>.json here, root-owned, chmod 0400.
  # This file is a SECRET — do not commit it to the repo.
  credentialsFile = "/var/lib/cloudflared/theater.json";
in {
  services.cloudflared = {
    enable = true;
    tunnels.${tunnelId} = {
      inherit credentialsFile;

      # Anything not matched below returns 404 instead of hitting the box.
      default = "http_status:404";

      ingress = {
        # --- Public (own auth, no Cloudflare Access) ---
        "vault.${domain}" = "http://localhost:8083"; # vaultwarden
        "requests.${domain}" = "http://localhost:5055"; # seerr
        "books.${domain}" = "http://localhost:3000"; # omnibus (has own auth)

        # --- Admin panels: put a Cloudflare Access policy in front of each ---
        "home.${domain}" = "http://localhost:7575"; # homarr
        "docker.${domain}" = "http://localhost:9000"; # portainer (docker mgmt)

        # The *arr / torrent / usenet stack is intentionally NOT here.
        # It is reached over Tailscale only, never published to public DNS.
      };
    };
  };
}
