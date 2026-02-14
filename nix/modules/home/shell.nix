{...}: {
  programs.starship.enable = true;
  programs.direnv.enable = true;
  programs.zoxide.enable = true;
  programs.zellij.enable = true;
  programs.fastfetch.enable = true;

  # Put the logo file in ~/.config/fastfetch/logo.png
  xdg.configFile."fastfetch/logo.png".source = ./theming/makima.jpg;

  # Write ~/.config/fastfetch/config.jsonc
  programs.fastfetch.settings = {
    logo = {
      type = "kitty";
      source = "~/.config/fastfetch/logo.png";
      width = 27;                # character columns - adjust up/down
      height = 19;               # matches number of output lines
      padding = {
        left = 1;
        top = 1;
      };
      preserveAspectRatio = true;
    };
    modules = [
      "title"
      "separator"
      "os"
      "host"
      "kernel"
      "uptime"
      "packages"
      "shell"
      "display"
      "de"
      "wm"
      "terminal"
      "cpu"
      "gpu"
      "memory"
      "disk"
      "break"
      "colors"
    ];
  };
}
