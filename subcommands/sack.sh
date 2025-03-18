#!/bin/bash
# Sack subcommand: manages sack syncing

cd "$HOME/.ruck" || { echo "Error: ~/.ruck not found."; exit 1; }

# Defaults
verbose=0
terse=0

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose) verbose=1; shift ;;
        --terse) terse=1; shift ;;
        sync) command="sync"; shift ;;
        *) break ;;  # Pass remaining args to scripts sync
    esac
done

if [ "$command" != "sync" ]; then
    echo "Usage: ruck sack [options] sync [scripts options]"
    echo "Options: --verbose, --terse"
    exit 1
fi

[ "$verbose" -eq 1 ] && echo "** Sack Subcommand Running **"

# Delegate to scripts sync, passing all remaining args and flags
bash "subcommands/scripts.sh" "$@" ${verbose:+--verbose} ${terse:+--terse}

[ "$terse" -eq 0 ] && echo "Sack sync complete."