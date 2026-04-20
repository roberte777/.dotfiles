{
  description = "Nix configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zeroclaw = {
      url = "github:zeroclaw-labs/zeroclaw";
      flake = false;
    };
    zesh = {
      url = "github:roberte777/zesh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-master,
    home-manager,
    nix-darwin,
    ...
  } @ inputs: let
    allSystems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs allSystems;
    mkNixosHost = {
      hostname,
      system,
      extraSpecialArgs ? {},
    }: let
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-master = import nixpkgs-master {
        inherit system;
      };
    in
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;} // extraSpecialArgs;
        modules = [
          ./hosts/${hostname}
          {nixpkgs.config.allowUnfree = true;}
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs pkgs-unstable pkgs-master;};
          }
        ];
      };
    mkDarwinHost = {
      hostname,
      extraSpecialArgs ? {},
    }: let
      system = "aarch64-darwin";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-master = import nixpkgs-master {
        inherit system;
      };
    in
      nix-darwin.lib.darwinSystem {
        specialArgs = {inherit inputs;} // extraSpecialArgs;
        modules = [
          ./hosts/${hostname}
          {nixpkgs.hostPlatform = system;}
          {nixpkgs.config.allowUnfree = true;}
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs pkgs-unstable pkgs-master;};
          }
        ];
      };
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    homeConfigurations = {
      "work" = let
        system = "aarch64-darwin";
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
        pkgs-master = import nixpkgs-master {
          inherit system;
        };
      in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {inherit inputs pkgs-unstable pkgs-master;};
          modules = [
            ./hosts/work/home.nix
          ];
        };
    };
    darwinConfigurations = {
      lorien = mkDarwinHost {
        hostname = "lorien";
      };
    };
    nixosConfigurations = {
      theater = mkNixosHost {
        hostname = "theater";
        system = "x86_64-linux";
      };
      dualb = mkNixosHost {
        hostname = "dualb";
        system = "x86_64-linux";
      };
    };
  };
}
