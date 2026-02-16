{pkgs, ...}: let
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

  home.packages = with pkgs; [
    everforestGtk
    gnome-themes-extra
    gtk-engine-murrine
    sassc
  ];
}
