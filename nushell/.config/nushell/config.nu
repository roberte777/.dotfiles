# config.nu
#
# Installed by:
# version = "0.106.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.config.show_banner = false
$env.config.buffer_editor = "nvim"
$env.EDITOR = "nvim"
$env.CARGO_HOME = ($env.HOME | path join ".cargo")
$env.BUN_INSTALL = ($env.HOME | path join ".bun")

# set up path
use std/util "path add"
path add "~/.local/bin"
path add ($env.CARGO_HOME | path join "bin")
path add "~/go/bin"
path add "/usr/local/go/bin"
path add "/usr/local/cuda/bin"
path add "~/.fly/bin"
path add ($env.BUN_INSTALL | path join "bin")


def openfortivpn [
] {
    sudo systemctl start systemd-resolved.service;
    sudo openfortivpn --set-dns=0 --pppd-use-peerdns=1
}

# Stuff that told me to put it at the end
source ~/.zoxide.nu
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")


use '/home/roberte777/.config/broot/launcher/nushell/br' *
