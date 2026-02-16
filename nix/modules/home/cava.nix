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
        #dracula
        gradient = 1;
        gradient_color_1 = "'#8BE9FD'";
        gradient_color_2 = "'#9AEDFE'";
        gradient_color_3 = "'#CAA9FA'";
        gradient_color_4 = "'#BD93F9'";
        gradient_color_5 = "'#FF92D0'";
        gradient_color_6 = "'#FF79C6'";
        gradient_color_7 = "'#FF6E67'";
        gradient_color_8 = "'#FF5555'";
      };
    };
  };
}
