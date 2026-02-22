{
  pkgs,
  inputs,
  ...
}: let
  zeroclaw = pkgs.rustPlatform.buildRustPackage {
    pname = "zeroclaw";
    version = "unstable";
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
}
