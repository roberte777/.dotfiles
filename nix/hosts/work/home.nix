{...}: {
  imports = [
    ../../modules/home/dev.nix
    ../../modules/home/shell.nix
    ../../modules/home/claude.nix
  ];

  home.username = "ethan.wilkes";
  home.homeDirectory = "/Users/ethan.wilkes";
  home.stateVersion = "26.05";

  # Work-only plugins (the flock-espresso marketplace) can't go in the public
  # repo, so this host keeps its own settings.json.
  programs.claude-config.exclude = ["settings.json"];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
