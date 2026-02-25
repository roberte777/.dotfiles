{...}: {
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
        # everforest
        # gradient = 1;
        # gradient_count = 6;
        # gradient_color_1 = "'#d3c6aa'"; # fg
        # gradient_color_2 = "'#a7c080'"; # green
        # gradient_color_3 = "'#83c092'"; # aqua
        # gradient_color_4 = "'#7fbbb3'"; # blue
        # gradient_color_5 = "'#d699b6'"; # purple
        # gradient_color_6 = "'#e67e80'"; # red
        # catppuccin mocha
        gradient = 1;
        gradient_color_1 = "'#89dceb'"; # sky
        gradient_color_2 = "'#74c7ec'"; # sapphire
        gradient_color_3 = "'#89b4fa'"; # blue
        gradient_color_4 = "'#b4befe'"; # lavender
        gradient_color_5 = "'#cba6f7'"; # mauve
        gradient_color_6 = "'#f5c2e7'"; # pink
        gradient_color_7 = "'#eba0ac'"; # maroon
        gradient_color_8 = "'#f38ba8'"; # red
      };
    };
  };
}
