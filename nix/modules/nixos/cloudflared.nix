{pkgs, ...}: let
  # Cloudflare emails hard-version deadlines; nixpkgs (even master) lags, so
  # pin the official binary. To bump: change version + fetch the new sha256
  # with `nix hash file` after downloading the amd64 release from GitHub.
  cloudflaredPinned = pkgs.runCommand "cloudflared-2026.10.4" {} ''
    mkdir -p $out/bin
    cp ${pkgs.fetchurl {
      url = "https://github.com/cloudflare/cloudflared/releases/download/2026.10.4/cloudflared-linux-amd64";
      sha256 = "sha256-rl6K3XiEsFMdZrvKRXDR3kkf9tpR5Ovn6xYM3yQdnkI=";
    }} $out/bin/cloudflared
    chmod +x $out/bin/cloudflared
  '';

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
    package = cloudflaredPinned;
    tunnels.${tunnelId} = {
      inherit credentialsFile;

      # Anything not matched below returns 404 instead of hitting the box.
      default = "http_status:404";

      ingress = {
        # --- Public (own auth, no Cloudflare Access) ---
        "kakashi.${domain}" = "http://localhost:8404"; # kakashi site (static, no secrets)
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
