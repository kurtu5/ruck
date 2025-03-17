#!/bin/bash
# Script subcommand: adds scripts to configs and symlinks them

verbose=0
configuration="minimal"

# Parse flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --verbose) verbose=1 ;;
        --configuration) configuration="$2"; shift ;;
        *) break ;;
    esac
    shift
done

command="$1"
shift

case "$command" in
    add)
        script_path="$1"
        if [ -z "$script_path" ]; then
            echo "Error: Specify a script path."
            exit 1
        fi
        script_name=$(basename "$script_path")
        mkdir -p "$HOME/.ruck/scripts/$configuration"
        cp "$script_path" "$HOME/.ruck/scripts/$configuration/$script_name"
        ln -sf "$HOME/.ruck/scripts/$configuration/$script_name" "$HOME/bin/$script_name"
        if [ "$verbose" -eq 1 ]; then
            echo "Added $script_name to $configuration config."
        fi
        ;;
    *)
        echo "Unknown script command: $command"
        echo "Usage: ruck script add <script_path> [--configuration <config>] [--verbose]"
        exit 1
        ;;
esac
