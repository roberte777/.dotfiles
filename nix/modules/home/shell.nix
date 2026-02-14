{...}: {
  programs.starship.enable = true;
  programs.direnv.enable = true;
  programs.zoxide.enable = true;
  programs.zellij.enable = true;
  programs.fastfetch.enable = true;
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "everforest-dark-hard";
    };
  };

  programs.cava = {
    enable = true;
    settings = {
      general = {
        framerate = 60;
        bars = 0; # 0 = auto
        bar_width = 2;
        bar_spacing = 1;
      };
      color = {
        gradient = 1;
        gradient_count = 6;
        gradient_color_1 = "'#d3c6aa'"; # fg
        gradient_color_2 = "'#a7c080'"; # green
        gradient_color_3 = "'#83c092'"; # aqua
        gradient_color_4 = "'#7fbbb3'"; # blue
        gradient_color_5 = "'#d699b6'"; # purple
        gradient_color_6 = "'#e67e80'"; # red
      };
    };
  };

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
