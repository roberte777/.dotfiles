#!/bin/bash

# Set the plugin directory
PLUGIN_DIR="$HOME/.config/tmux/plugins/catppuccin"

# Clone the Catppuccin tmux plugin (if not already cloned)
if [ ! -d "$PLUGIN_DIR/tmux" ]; then
    echo "Cloning Catppuccin tmux plugin..."
    mkdir -p "$PLUGIN_DIR"
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$PLUGIN_DIR/tmux"
else
    echo "Catppuccin tmux plugin already exists at $PLUGIN_DIR/tmux"
fi

# Reload tmux configuration if inside a tmux session
if tmux info &>/dev/null; then
    echo "Reloading tmux configuration..."
    tmux source-file "$HOME/.tmux.conf"
else
    echo "Tmux is not running. Start tmux and run 'tmux source ~/.tmux.conf' manually."
fi

echo "Setup complete. Remember to add the plugin line to your .tmux.conf if you haven't already."

