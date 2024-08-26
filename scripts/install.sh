#!/bin/bash

# Function to print a formatted message with a step number
print_step() {
    local step_number=$1
    local step_message=$2
    echo -e "\n\033[1;34m[Step $step_number]\033[0m $step_message"
}

# Function to handle errors and exit if a command fails
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31m[Error]\033[0m $1"
        exit 1
    fi
}

# Step 1: Backup existing Neovim configuration
print_step 1 "Backing up existing Neovim configuration..."
if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
    check_success "Failed to backup ~/.config/nvim"
    echo "Backup of existing Neovim configuration created at ~/.config/nvim.bak"
else
    echo "No existing Neovim configuration found, skipping backup."
fi

# Step 2: Optional backups
print_step 2 "Backing up optional Neovim directories..."
for dir in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
    if [ -d "$dir" ]; then
        mv "$dir" "$dir.bak"
        check_success "Failed to backup $dir"
        echo "Backup of existing $(basename $dir) created at ${dir}.bak"
    else
        echo "No existing $(basename $dir) found, skipping backup."
    fi
done

# Step 3: Clone the Neovim configuration repository
print_step 3 "Cloning the Neovim configuration repository..."
git clone https://github.com/franciscoavilaluna/nvim "$HOME/.config/nvim"
check_success "Failed to clone the Neovim configuration repository"

# Step 4: Final message
print_step 4 "Installation complete!"
echo "You can start Neovim by typing 'nvim'."

