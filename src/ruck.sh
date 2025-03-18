#!/bin/bash
# Ruck main script: runs subcommands

cd "$HOME/.ruck" || { echo "Error: ~/.ruck not found."; exit 1; }

# Log every command
echo "$(date): $@" >> "$HOME/.ruck/history.log"

subcommand="$1"
shift

if [ -z "$subcommand" ]; then
    echo "Usage: ruck <subcommand> [args]"
    exit 1
fi

if [ -f "subcommands/$subcommand.sh" ]; then
    bash "subcommands/$subcommand.sh" "$@"
else
    echo "Unknown subcommand: $subcommand"
    echo "Usage: ruck <subcommand> [args]"
    exit 1
fi