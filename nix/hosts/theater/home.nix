{...}: {
  home-manager.users.theater = {
    imports = [
      ../../modules/home/dev.nix
      ../../modules/home/shell.nix
    ];

    home.stateVersion = "25.11";
  };
}
