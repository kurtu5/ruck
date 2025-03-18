#!/bin/bash
# Setup script for Ruck: moves repo to ~/.ruck/, sets up symlink, and runs initial sync

# Get the script's directory (not the caller's pwd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure ~/bin/ exists
mkdir -p "$HOME/bin"

# Move this repo to ~/.ruck/
if [ ! -d "$HOME/.ruck" ]; then
    echo "Moving Ruck repo to ~/.ruck/"
    mv "$SCRIPT_DIR" "$HOME/.ruck"
else
    echo "Updating existing Ruck repo at ~/.ruck/"
    mv "$SCRIPT_DIR"/* "$HOME/.ruck/"
    rm -rf "$SCRIPT_DIR"  # Clean up temp dir after moving
fi

# Symlink ruck.sh to ~/bin/ruck
ln -sf "$HOME/.ruck/src/ruck.sh" "$HOME/bin/ruck"

# Ensure ~/.ruck/dotfiles/minimal/ exists and create .bashrc_ruck
mkdir -p "$HOME/.ruck/dotfiles/minimal"
cat > "$HOME/.ruck/dotfiles/minimal/.bashrc_ruck" << 'EOF'
#!/bin/bash
export PATH="$HOME/bin:$PATH"
EOF

# Add sourcing to ~/.bashrc if not already there
if ! grep -q "source.*\.bashrc_ruck" "$HOME/.bashrc"; then
    echo "source ~/.ruck/dotfiles/minimal/.bashrc_ruck" >> "$HOME/.bashrc"
    echo "Added sourcing of .bashrc_ruck to ~/.bashrc. Run 'source ~/.bashrc' to apply."
else
    echo ".bashrc_ruck already sourced in ~/.bashrc."
fi

# Run initial sync
echo "Running initial core sync..."
"$HOME/bin/ruck" core sync

echo "Ruck setup done! Run 'ruck' to test it."
