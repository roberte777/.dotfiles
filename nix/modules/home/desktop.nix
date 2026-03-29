{pkgs, ...}: {
  home.packages = with pkgs; [
    # File managers
    kdePackages.dolphin
    kdePackages.qtsvg # SVG icon support
    kdePackages.kio-extras # Extra protocols (trash, etc.)
    nautilus # GTK file manager

    # Notes
    obsidian
  ];

  programs.vesktop = {
    enable = true;
    vencord.settings = {
      autoUpdate = true;
      notifyAboutUpdates = true;
      useQuickCss = true;
      enabledThemes = ["catppuccin-mocha.css"];
    };
    vencord.themes.catppuccin-mocha = ''
      /**
       * @name Catppuccin Mocha
       * @description Catppuccin Mocha color scheme for Discord
       * @author Catppuccin
       * @version 1.0.0
       * @BDEditor DiscordRecolor
       */

      @import url('https://mwittrien.github.io/BetterDiscordAddons/Themes/DiscordRecolor/DiscordRecolor.css');

      :root {
        --accentcolor: 203,166,247;
        --accentcolor2: 245,194,231;
        --linkcolor: 137,180,250;
        --mentioncolor: 250,179,135;
        --textbrightest: 205,214,244;
        --textbrighter: 186,194,222;
        --textbright: 166,173,200;
        --textdark: 147,153,178;
        --textdarker: 127,132,156;
        --textdarkest: 108,112,134;
        --backgroundaccent: 88,91,112;
        --backgroundprimary: 30,30,46;
        --backgroundsecondary: 24,24,37;
        --backgroundsecondaryalt: 24,24,37;
        --backgroundtertiary: 17,17,27;
        --backgroundfloating: 30,30,46;
        --settingsicons: 1;
      }
    '';
    vencord.themes.everforest = ''
      /**
       * @name Everforest
       * @description Everforest color scheme for Discord
       * @author DevilBro
       * @version 1.0.0
       * @BDEditor DiscordRecolor
       */

      @import url('https://fonts.googleapis.com/css2?family=Ubuntu+Sans:wght@100;300;400;500;700&display=swap');
      @import url('https://mwittrien.github.io/BetterDiscordAddons/Themes/DiscordRecolor/DiscordRecolor.css');

      :root {
        --accentcolor: 167,192,128;
        --accentcolor2: 255,115,250;
        --linkcolor: 127,187,179;
        --mentioncolor: 230,152,117;
        --textbrightest: 211,198,170;
        --textbrighter: 211,198,170;
        --textbright: 211,198,170;
        --textdark: 211,198,170;
        --textdarker: 211,198,170;
        --textdarkest: 211,198,170;
        --font: Ubuntu Sans;
        --backgroundaccent: 61,72,77;
        --backgroundprimary: 52,63,68;
        --backgroundsecondary: 45,53,59;
        --backgroundsecondaryalt: 45,53,59;
        --backgroundtertiary: 45,53,59;
        --backgroundfloating: 52,63,68;
        --settingsicons: 1;
      }
    '';
  };
}
