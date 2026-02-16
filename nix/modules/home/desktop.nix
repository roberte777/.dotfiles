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
      enabledThemes = ["dracula.css"];
    };
    vencord.themes.dracula = ''
      /**
       * @name Dracula
       * @description Dracula color scheme for Discord
       * @author Dracula Theme
       * @version 1.0.0
       * @BDEditor DiscordRecolor
       */

      @import url('https://mwittrien.github.io/BetterDiscordAddons/Themes/DiscordRecolor/DiscordRecolor.css');

      :root {
        --accentcolor: 189,147,249;
        --accentcolor2: 255,121,198;
        --linkcolor: 139,233,253;
        --mentioncolor: 255,184,108;
        --textbrightest: 248,248,242;
        --textbrighter: 248,248,242;
        --textbright: 248,248,242;
        --textdark: 98,114,164;
        --textdarker: 68,71,90;
        --textdarkest: 68,71,90;
        --backgroundaccent: 68,71,90;
        --backgroundprimary: 40,42,54;
        --backgroundsecondary: 33,34,44;
        --backgroundsecondaryalt: 33,34,44;
        --backgroundtertiary: 21,22,30;
        --backgroundfloating: 40,42,54;
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
