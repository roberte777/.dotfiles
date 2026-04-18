# Default recipe to display help
default:
    @just --list

# Switch with specific configuration
switch config:
    home-manager switch --flake .#{{config}}

# Switch with specific configuration
rebuild config:
    sudo nixos-rebuild switch --flake .#{{config}}

# Rebuild nix-darwin configuration
darwin config:
    sudo darwin-rebuild switch --flake .#{{config}}

# Bootstrap home-manager (first-time setup with flakes)
bootstrap config:
    nix run home-manager -- switch --flake .#{{config}}

# Clean old generations
clean:
    home-manager expire-generations "-7 days"

fmt:
    nix fmt .

update-all:
    nix flake update

update-stable:
    nix flake update nixpkgs

update-unstable:
    nix flake update nixpkgs-unstable
