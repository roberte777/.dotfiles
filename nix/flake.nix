{
  description = "Nix configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    allSystems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs allSystems;

    # Helper to create NixOS configurations with home-manager
    mkNixosHost = {
      hostname,
      system ? "x86_64-linux",
      extraSpecialArgs ? {},
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;} // extraSpecialArgs;
        modules = [
          ./hosts/${hostname}
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    homeConfigurations = {
      "work" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./hosts/work/home.nix
        ];
      };
    };

    nixosConfigurations = {
      theater = mkNixosHost {hostname = "theater";};
      dualb = mkNixosHost {hostname = "dualb";};
    };
  };
}
