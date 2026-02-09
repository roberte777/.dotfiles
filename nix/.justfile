# Default recipe to display help
default:
    @just --list

# Switch with specific configuration
switch config:
    home-manager switch --flake .#{{config}}

# Bootstrap home-manager (first-time setup with flakes)
bootstrap config:
    nix run home-manager -- switch --flake .#{{config}}

# Clean old generations
clean:
    home-manager expire-generations "-7 days"
