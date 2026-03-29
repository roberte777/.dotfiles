{
  lib,
  config,
  ...
}: let
  cfg = config.programs.firefox-themed;

  catppuccinMochaTheme = {
    userChrome = ''
      /* Catppuccin Mocha Theme for Firefox */
      :root {
        --ctp-rosewater: #f5e0dc;
        --ctp-flamingo: #f2cdcd;
        --ctp-pink: #f5c2e7;
        --ctp-mauve: #cba6f7;
        --ctp-red: #f38ba8;
        --ctp-maroon: #eba0ac;
        --ctp-peach: #fab387;
        --ctp-yellow: #f9e2af;
        --ctp-green: #a6e3a1;
        --ctp-teal: #94e2d5;
        --ctp-sky: #89dceb;
        --ctp-sapphire: #74c7ec;
        --ctp-blue: #89b4fa;
        --ctp-lavender: #b4befe;
        --ctp-text: #cdd6f4;
        --ctp-subtext1: #bac2de;
        --ctp-subtext0: #a6adc8;
        --ctp-overlay2: #9399b2;
        --ctp-overlay1: #7f849c;
        --ctp-overlay0: #6c7086;
        --ctp-surface2: #585b70;
        --ctp-surface1: #45475a;
        --ctp-surface0: #313244;
        --ctp-base: #1e1e2e;
        --ctp-mantle: #181825;
        --ctp-crust: #11111b;

        /* Firefox color mappings */
        --lwt-accent-color: var(--ctp-base) !important;
        --lwt-text-color: var(--ctp-text) !important;
        --toolbar-bgcolor: var(--ctp-base) !important;
        --toolbar-color: var(--ctp-text) !important;
        --toolbar-field-background-color: var(--ctp-surface0) !important;
        --toolbar-field-color: var(--ctp-text) !important;
        --toolbar-field-border-color: var(--ctp-surface1) !important;
        --toolbar-field-focus-background-color: var(--ctp-base) !important;
        --toolbar-field-focus-border-color: var(--ctp-mauve) !important;
        --urlbar-popup-url-color: var(--ctp-sapphire) !important;
        --tab-selected-bgcolor: var(--ctp-surface0) !important;
        --tab-selected-textcolor: var(--ctp-text) !important;
        --tab-loading-fill: var(--ctp-mauve) !important;
        --arrowpanel-background: var(--ctp-base) !important;
        --arrowpanel-color: var(--ctp-text) !important;
        --arrowpanel-border-color: var(--ctp-surface0) !important;
      }

      /* Tab bar background */
      #TabsToolbar {
        background-color: var(--ctp-mantle) !important;
      }

      /* Active tab */
      .tab-background[selected="true"] {
        background-color: var(--ctp-base) !important;
      }

      /* Inactive tabs */
      .tab-background:not([selected="true"]) {
        background-color: var(--ctp-mantle) !important;
      }

      /* Navigation bar */
      #nav-bar {
        background-color: var(--ctp-base) !important;
        border-bottom: 1px solid var(--ctp-surface0) !important;
      }

      /* URL bar */
      #urlbar-background {
        background-color: var(--ctp-surface0) !important;
        border-color: var(--ctp-surface1) !important;
      }

      #urlbar[focused="true"] > #urlbar-background {
        border-color: var(--ctp-mauve) !important;
      }

      /* Bookmarks bar */
      #PersonalToolbar {
        background-color: var(--ctp-mantle) !important;
      }

      /* Sidebar */
      #sidebar-box {
        background-color: var(--ctp-mantle) !important;
        color: var(--ctp-text) !important;
      }

      /* Menu popup panels */
      menupopup, panel {
        --panel-background: var(--ctp-base) !important;
        --panel-color: var(--ctp-text) !important;
      }
    '';
    userContent = ''
      /* Catppuccin Mocha for Firefox internal pages */
      @-moz-document url("about:newtab"), url("about:home"), url("about:blank") {
        body {
          background-color: #1e1e2e !important;
        }
      }
    '';
  };

  everforestTheme = {
    userChrome = ''
      /* Everforest Dark Theme for Firefox */
      :root {
        --everforest-bg-dim: #232A2E;
        --everforest-bg0: #2D353B;
        --everforest-bg1: #343F44;
        --everforest-bg2: #3D484D;
        --everforest-bg3: #475258;
        --everforest-bg4: #4F585E;
        --everforest-fg: #D3C6AA;
        --everforest-grey0: #7A8478;
        --everforest-grey1: #859289;
        --everforest-grey2: #9DA9A0;
        --everforest-red: #E67E80;
        --everforest-orange: #E69875;
        --everforest-yellow: #DBBC7F;
        --everforest-green: #A7C080;
        --everforest-aqua: #83C092;
        --everforest-blue: #7FBBB3;
        --everforest-purple: #D699B6;

        /* Firefox color mappings */
        --lwt-accent-color: var(--everforest-bg0) !important;
        --lwt-text-color: var(--everforest-fg) !important;
        --toolbar-bgcolor: var(--everforest-bg1) !important;
        --toolbar-color: var(--everforest-fg) !important;
        --toolbar-field-background-color: var(--everforest-bg2) !important;
        --toolbar-field-color: var(--everforest-fg) !important;
        --toolbar-field-border-color: var(--everforest-bg3) !important;
        --toolbar-field-focus-background-color: var(--everforest-bg1) !important;
        --toolbar-field-focus-border-color: var(--everforest-green) !important;
        --urlbar-popup-url-color: var(--everforest-green) !important;
        --tab-selected-bgcolor: var(--everforest-bg2) !important;
        --tab-selected-textcolor: var(--everforest-fg) !important;
        --tab-loading-fill: var(--everforest-green) !important;
        --arrowpanel-background: var(--everforest-bg1) !important;
        --arrowpanel-color: var(--everforest-fg) !important;
        --arrowpanel-border-color: var(--everforest-bg3) !important;
      }

      /* Tab bar background */
      #TabsToolbar {
        background-color: var(--everforest-bg-dim) !important;
      }

      /* Active tab */
      .tab-background[selected="true"] {
        background-color: var(--everforest-bg1) !important;
      }

      /* Inactive tabs */
      .tab-background:not([selected="true"]) {
        background-color: var(--everforest-bg0) !important;
      }

      /* Navigation bar */
      #nav-bar {
        background-color: var(--everforest-bg1) !important;
        border-bottom: 1px solid var(--everforest-bg3) !important;
      }

      /* URL bar */
      #urlbar-background {
        background-color: var(--everforest-bg2) !important;
        border-color: var(--everforest-bg3) !important;
      }

      #urlbar[focused="true"] > #urlbar-background {
        border-color: var(--everforest-green) !important;
      }

      /* Bookmarks bar */
      #PersonalToolbar {
        background-color: var(--everforest-bg0) !important;
      }

      /* Sidebar */
      #sidebar-box {
        background-color: var(--everforest-bg0) !important;
        color: var(--everforest-fg) !important;
      }

      /* Menu popup panels */
      menupopup, panel {
        --panel-background: var(--everforest-bg1) !important;
        --panel-color: var(--everforest-fg) !important;
      }
    '';
    userContent = ''
      /* Everforest for Firefox internal pages */
      @-moz-document url("about:newtab"), url("about:home"), url("about:blank") {
        body {
          background-color: #2D353B !important;
        }
      }
    '';
  };

  themes = {
    catppuccin-mocha = catppuccinMochaTheme;
    everforest = everforestTheme;
  };

  selectedTheme = themes.${cfg.theme};
in {
  options.programs.firefox-themed = {
    enable = lib.mkEnableOption "Firefox with theme support";

    theme = lib.mkOption {
      type = lib.types.enum ["catppuccin-mocha" "everforest"];
      default = "catppuccin-mocha";
      description = "The color theme to use for Firefox";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        isDefault = true;
        settings = {
          # Enable userChrome.css
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          # Dark theme preference
          "ui.systemUsesDarkTheme" = 1;
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;
        };
        userChrome = selectedTheme.userChrome;
        userContent = selectedTheme.userContent;
      };
    };
  };
}
