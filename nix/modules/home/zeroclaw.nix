{
  pkgs,
  inputs,
  ...
}: let
  zeroclaw = pkgs.rustPlatform.buildRustPackage {
    pname = "zeroclaw";
    version = "0.1.5";
    src = inputs.zeroclaw;
    cargoLock.lockFile = "${inputs.zeroclaw}/Cargo.lock";

    nativeBuildInputs = with pkgs; [
      pkg-config
    ];

    buildInputs = with pkgs; [
      openssl
      sqlite
    ];
  };
in {
  home.packages = [zeroclaw];

  systemd.user.services.zeroclaw = {
    Unit = {
      Description = "ZeroClaw AI agent";
      After = ["network-online.target"];
    };
    Service = {
      ExecStart = "${zeroclaw}/bin/zeroclaw";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
