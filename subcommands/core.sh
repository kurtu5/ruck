#!/bin/bash
# Core subcommand: handles core Ruck features like sync

cd "$HOME/.ruck" || { echo "Error: ~/.ruck not found."; exit 1; }

case "$1" in
    sync)
        # Sync Git repo
        git pull origin master
        git add .
        git commit -m "Sync from $(hostname) at $(date)" || echo "Nothing to commit."
        git push origin master

        # Ensure scripts/minimal/ exists
        mkdir -p "$HOME/.ruck/scripts/minimal"

        # Sync ~/bin/ to ~/.ruck/scripts/minimal/
        for script in "$HOME/bin/"*; do
            if [ -f "$script" ] && [ ! -L "$script" ]; then  # Only non-symlinks
                script_name=$(basename "$script")
                minimal_path="$HOME/.ruck/scripts/minimal/$script_name"
                if [ ! -f "$minimal_path" ] || ! cmp -s "$script" "$minimal_path"; then
                    echo "Updating $script_name in minimal config"
                    cp "$script" "$minimal_path"
                fi
            fi
        done

        # Sync ~/.ruck/scripts/minimal/ to ~/bin/
        for script in "$HOME/.ruck/scripts/minimal/"*; do
            if [ -f "$script" ]; then
                script_name=$(basename "$script")
                bin_path="$HOME/bin/$script_name"
                if [ ! -f "$bin_path" ] || ! cmp -s "$script" "$bin_path"; then
                    echo "Syncing $script_name to ~/bin/"
                    ln -sf "$script" "$bin_path"
                fi
            fi
        done

        echo "Core sync complete."
        ;;
    *)
        echo "Unknown core command: $1"
        echo "Usage: ruck core <sync>"
        exit 1
        ;;
esac