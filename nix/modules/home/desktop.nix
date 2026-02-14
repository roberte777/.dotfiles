{pkgs, ...}: {
  home.packages = with pkgs; [
    # File managers
    kdePackages.dolphin
    kdePackages.qtsvg # SVG icon support
    kdePackages.kio-extras # Extra protocols (trash, etc.)
    nautilus # GTK file manager
  ];
}
