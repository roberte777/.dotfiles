{pkgs, ...}: {
  home.packages = with pkgs; [
    imv # Wayland image viewer
    hyprpicker # Color picker
    wf-recorder # Screen recording
  ];

  programs.mpv = {
    enable = true;
    config = {
      osd-font = "JetBrainsMono Nerd Font";
      osd-font-size = 24;
      osd-color = "#f8f8f2";
      osd-border-color = "#282a36";
    };
  };

  programs.zathura = {
    enable = true;
    options = {
      default-bg = "#282a36";
      default-fg = "#f8f8f2";
      statusbar-bg = "#282a36";
      statusbar-fg = "#f8f8f2";
      inputbar-bg = "#282a36";
      inputbar-fg = "#f8f8f2";
      recolor-lightcolor = "#282a36";
      recolor-darkcolor = "#f8f8f2";
      recolor = true;
      recolor-keephue = true;
    };
  };
}
