#!/bin/bash
# Scripts subcommand: manages script syncing for Ruck sack

cd "$HOME/.ruck" || { echo "Error: ~/.ruck not found."; exit 1; }

# Defaults
scripts_dir="bin"
config_name=$(cat "$HOME/.ruck/current_config" 2>/dev/null || echo "minimal")
verbose=0
terse=0
conflict_action="prompt"

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose) verbose=1; shift ;;
        --terse) terse=1; shift ;;
        --sack|--configuration) config_name="$2"; shift 2 ;;
        --conflicts-use-local) conflict_action="local"; shift ;;
        --conflicts-use-remote) conflict_action="remote"; shift ;;
        --conflicts-skip) conflict_action="skip"; shift ;;
        --conflicts-edit) conflict_action="edit"; shift ;;
        sync) command="sync"; shift ;;
        *) echo "Unknown option or command: $1"; exit 1 ;;
    esac
done

if [ "$command" != "sync" ]; then
    echo "Usage: ruck scripts [options] sync"
    echo "Options: --verbose, --terse, --sack <name>, --conflicts-<use-local|use-remote|skip|edit>"
    exit 1
fi

# Sync logic
[ "$verbose" -eq 1 ] && echo "** Scripts Subcommand Running **"
[ "$verbose" -eq 1 ] && echo "Using configuration_name=$config_name"

# Ensure scripts dir exists
mkdir -p "$HOME/.ruck/$scripts_dir/$config_name"

# Check Git state
if [ "$verbose" -eq 1 ]; then
    echo "** Checking state with git"
    git status
fi

# Pull from remote
if ! git pull origin master >/dev/null 2>&1; then
    if [ "$terse" -eq 0 ]; then
        echo "Conflict detected during pull."
    fi
    case "$conflict_action" in
        prompt)
            if [ "$terse" -eq 0 ]; then
                echo "Conflict detected in sack sync:"
                echo "You have changes on local and remote."
                echo "1) Keep the local version"
                echo "2) Keep the remote version"
                echo "3) Skip sync"
                read -p "Choice: " choice
            else
                echo "Conflict detected, but --terse requires a --conflicts option. Aborting."
                exit 1
            fi
            case "$choice" in
                1) git reset --hard HEAD; git add .; git commit -m "Sync: kept local from $(hostname) at $(date)"; git push origin master ;;
                2) git fetch; git reset --hard origin/master ;;
                3) echo "Skipping sync."; exit 0 ;;
                *) echo "Invalid choice. Aborting."; exit 1 ;;
            esac
            ;;
        local) git reset --hard HEAD; git add .; git commit -m "Sync: kept local from $(hostname) at $(date)"; git push origin master ;;
        remote) git fetch; git reset --hard origin/master ;;
        skip) [ "$terse" -eq 0 ] && echo "Skipping sync."; exit 0 ;;
        edit) echo "Edit mode not implemented yet. Aborting."; exit 1 ;;
    esac
fi

# Sync scripts
for script in "$HOME/bin/"*; do
    if [ -f "$script" ] && [ ! -L "$script" ]; then
        script_name=$(basename "$script")
        config_path="$HOME/.ruck/$scripts_dir/$config_name/$script_name"
        if [ ! -f "$config_path" ] || ! cmp -s "$script" "$config_path"; then
            [ "$verbose" -eq 1 ] && echo "Updating $script_name in $config_name config"
            cp "$script" "$config_path"
        fi
    fi
done

for script in "$HOME/.ruck/$scripts_dir/$config_name/"*; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        bin_path="$HOME/bin/$script_name"
        if [ ! -f "$bin_path" ] || ! cmp -s "$script" "$bin_path"; then
            [ "$verbose" -eq 1 ] && echo "Syncing $script_name to ~/bin/"
            ln -sf "$script" "$bin_path"
        fi
    fi
done

# Commit and push
git add .
git commit -m "Sync from $(hostname) at $(date)" || [ "$verbose" -eq 1 ] && echo "Nothing to commit."
git push origin master