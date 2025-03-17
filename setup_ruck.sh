#!/bin/bash
# Setup script for Ruck: clones repo, sets up symlinks, and adds ~/bin/ to PATH

# Check if ~/.ruck exists
if [ ! -d "$HOME/.ruck" ]; then
    echo "Cloning Ruck repo to ~/.ruck/"
    git clone https://github.com/kurtu5/ruck.git "$HOME/.ruck"
else
    echo "Updating existing Ruck repo..."
    cd "$HOME/.ruck"
    git pull origin main
fi

# Ensure ~/bin/ exists
mkdir -p "$HOME/bin"

# Symlink ruck.sh to ~/bin/ruck
ln -sf "$HOME/.ruck/src/ruck.sh" "$HOME/bin/ruck"

# Add ~/bin/ to PATH if not already there
if ! echo "$PATH" | grep -q "$HOME/bin"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    echo "Added ~/bin/ to PATH in .bashrc. Run 'source ~/.bashrc' to apply."
else
    echo "~/bin/ already in PATH."
fi

echo "Ruck setup done! Run 'ruck' to test it."
