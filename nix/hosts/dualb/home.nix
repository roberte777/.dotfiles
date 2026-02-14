{
  pkgs,
  inputs,
  ...
}: let
  # Everforest Kvantum theme from GitHub
  everforestKvantum = pkgs.stdenvNoCC.mkDerivation {
    pname = "materia-everforest-kvantum";
    version = "unstable-2024-01-01";
    src = pkgs.fetchFromGitHub {
      owner = "binEpilo";
      repo = "materia-everforest-kvantum";
      rev = "main";
      sha256 = "sha256-5ihKScPJMDU0pbeYtUx/UjC4J08/r40mAK7D+1TK6wA=";
    };
    installPhase = ''
      mkdir -p $out/share/Kvantum/MateriaEverforestDark
      cp MateriaEverforestDark/* $out/share/Kvantum/MateriaEverforestDark/
    '';
  };

  # Everforest GTK theme from GitHub (latest version with window button fixes)
  everforestGtk = pkgs.stdenvNoCC.mkDerivation {
    pname = "everforest-gtk-theme";
    version = "unstable-2025-02-12";
    src = pkgs.fetchFromGitHub {
      owner = "Fausto-Korpsvart";
      repo = "Everforest-GTK-Theme";
      rev = "9b8be4d6648ae9eaae3dd550105081f8c9054825";
      sha256 = "sha256-XHO6NoXJwwZ8gBzZV/hJnVq5BvkEKYWvqLBQT00dGdE=";
    };
    nativeBuildInputs = with pkgs; [
      sassc
      gtk3
      gnome-themes-extra
      gtk-engine-murrine
    ];
    installPhase = ''
      mkdir -p $out/share/themes
      cd themes
      bash install.sh -d $out/share/themes -n Everforest -c dark -t default -s standard
    '';
  };
in {
  # import the nixos module
  imports = [
    inputs.noctalia.nixosModules.default
  ];
  # enable the systemd service
  services.noctalia-shell.enable = true;
  home-manager.users.roberte777 = {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "25.11";

    programs.git = {
      enable = true;
      userName = "roberte777";
      userEmail = "rewilkes0041@gmail.com";
    };
    programs.starship.enable = true;
    programs.direnv.enable = true;
    programs.zoxide.enable = true;
    programs.zellij.enable = true;
    programs.jujutsu.enable = true;
    programs.ripgrep.enable = true;
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    programs.noctalia-shell = {
      enable = true;
    };

    # GTK Everforest theme
    gtk = {
      enable = true;
      theme = {
        name = "Everforest-Dark";
        package = everforestGtk;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "Adwaita";
        size = 24;
      };
    };

    # Qt theming with Kvantum Everforest
    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    # Kvantum Everforest theme configuration
    xdg.configFile."Kvantum/MateriaEverforestDark".source = "${everforestKvantum}/share/Kvantum/MateriaEverforestDark";
    xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=MateriaEverforestDark
    '';

    # Firefox with Everforest theme
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
    };

    home.packages = with pkgs; [
      claude-code
      lazyjj
      fd
      jq
      tree
      curl
      wget
      just
      gh

      #theming
      everforestGtk
      gnome-themes-extra
      gtk-engine-murrine
      sassc

      # File managers
      kdePackages.dolphin
      kdePackages.qtsvg # SVG icon support
      kdePackages.kio-extras # Extra protocols (trash, etc.)
      nautilus # GTK - uses Everforest theme directly
    ];
  };
}
