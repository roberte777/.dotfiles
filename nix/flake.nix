{
  description = "Nix configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
  } @ inputs: let
    systems = {
      darwin = "aarch64-darwin";
      linux = "x86_64-linux";
    };
    # hosts = [ "xos" ];
  in {
    formatter.${systems.darwin} = nixpkgs.legacyPackages.${systems.darwin}.alejandra;

    homeConfigurations = {
      "work" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${systems.darwin};
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./hosts/work/home.nix
        ];
      };
    };

    nixosConfigurations = {
      theater = nixpkgs.lib.nixosSystem {
        system = systems.linux;
        modules = [
          ./hosts/theater
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
      dualb = nixpkgs.lib.nixosSystem {
        system = systems.linux;
        modules = [
          ./hosts/dualb
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };
    # use mr Jon as an example: https://github.com/jonhoo/configs/blob/master/nix/flake.nix
    # nixosConfigurations = nixpkgs.lib.genAttrs hosts (
    #   name:
    #   nixpkgs.lib.nixosSystem {
    #     inherit system;
    #     specialArgs = {
    #       llm-agents = llm-agents.packages.${system};
    #     };
    #     modules = [
    #       ./hosts/${name}
    #       home-manager.nixosModules.home-manager
    #       {
    #         home-manager.extraSpecialArgs = {
    #           llm-agents = llm-agents.packages.${system};
    #         };
    #       }
    #     ];
    #   }
    # );
  };
}
