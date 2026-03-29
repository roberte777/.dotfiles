{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    inputs.zesh.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
