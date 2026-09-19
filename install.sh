V#!/usr/bin/env bash

set -e

echo "Starting Neovim Setup Installation..."

OS_TYPE=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_TYPE=$ID
fi

echo "Detected System: $OS_TYPE"

install_arch() {
    echo "Installing dependencies on Arch Linux..."
    sudo pacman -Syu --needed --noconfirm \
        neovim git base-devel gcc make unzip curl gzip tar \
        ripgrep fd fzf python python-pip nodejs npm openjdk-src clang \
        typst ttf-nerd-fonts-symbols-common tree-sitter-cli

    if ! command -v yay &> /dev/null; then
        echo "Installing yay for AUR packages..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm && cd - && rm -rf /tmp/yay
    fi

    yay -S --needed --noconfirm tinymist typstyle
}

install_debian() {
    echo "Installing dependencies on Debian/Ubuntu..."
    sudo apt update && sudo apt install -y \
        neovim git build-essential gcc make unzip curl gzip tar \
        ripgrep fd-find fzf python3 python3-pip nodejs npm \
        default-jdk clang

    if ! command -v cargo &> /dev/null; then
        echo "Installing Rust/Cargo..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    echo "Installing tinymist and typstyle via cargo..."
    cargo install --locked tinymist typstyle
}

install_fedora() {
    echo "Installing dependencies on Fedora..."
    sudo dnf check-update || true
    sudo dnf install -y \
        neovim git @development-tools gcc make unzip curl gzip tar \
        ripgrep fd-find fzf python3 python3-pip nodejs npm \
        java-latest-openjdk clang

    if ! command -v cargo &> /dev/null; then
        sudo dnf install -y cargo
    fi

    echo "Installing tinymist and typstyle via cargo..."
    cargo install --locked tinymist typstyle
}

install_alpine() {
    echo "Installing dependencies on Alpine Linux..."
    sudo apk add --no-confirm \
        neovim git build-base gcc make unzip curl tar \
        ripgrep fd fzf python3 py3-pip nodejs npm \
        openjdk17 clang cargo

    echo "Installing tinymist and typstyle via cargo..."
    cargo install --locked tinymist typstyle
}

case "$OS_TYPE" in
    arch|manjaro|endeavouros)
        install_arch
        ;;
    ubuntu|debian|pop|mint)
        install_debian
        ;;
    fedora|rhel|centos)
        install_fedora
        ;;
    alpine)
        install_alpine
        ;;
    *)
        echo "⚠️ Unofficial distribution detected ($OS_TYPE). Attempting generic package installation..."
        if command -v pacman &> /dev/null; then install_arch;
        elif command -v apt-get &> /dev/null; then install_debian;
        elif command -v dnf &> /dev/null; then install_fedora;
        else
            echo "❌ Package manager not supported. Please install dependencies manually."
            exit 1
        fi
        ;;
esac

if ! command -v tree-sitter &> /dev/null; then
    echo "Installing tree-sitter-cli (needed by nvim-treesitter to compile parsers like sql that ship without pre-generated C source)..."
    sudo npm install -g tree-sitter-cli
fi

if [ -d "$HOME/.config/nvim" ] && [ "$HOME/.config/nvim" != "$(pwd)" ]; then
    echo "Backing up existing configuration to ~/.config/nvim.bak..."
    rm -rf "$HOME/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi

if [ ! -f "init.lua" ]; then
    echo "Cloning repository..."
    git clone https://github.com/franciscoavilaluna/nvim.git "$HOME/.config/nvim"
fi

echo "Installing and syncing plugins with Lazy.nvim..."
nvim --headless "+Lazy! sync" +qa

echo "Installation completed successfully! Run 'nvim' to start."

