#!/bin/bash
# Ruck main script: syncs changes and runs subcommands

cd "$HOME/.ruck" || { echo "Error: ~/.ruck not found."; exit 1; }

# Log every command
echo "$(date): $@" >> "$HOME/.ruck/history.log"

case "$1" in
    sync)
        git pull origin master
        git add .
        git commit -m "Sync from $(hostname) at $(date)" || echo "Nothing to commit."
        git push origin maaster
        echo "Sync complete."
        ;;
    *)
        subcommand="$1"
        shift
        if [ -f "subcommands/$subcommand.sh" ]; then
            bash "subcommands/$subcommand.sh" "$@"
        else
            echo "Unknown command: $subcommand"
            echo "Usage: ruck [sync | subcommand]"
            exit 1
        fi
        ;;
esac
