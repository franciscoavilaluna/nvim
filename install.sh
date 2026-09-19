#!/usr/bin/env bash

set -e

echo "🚀 Iniciando instalación completa para el setup de Neovim en Arch Linux..."

echo "📦 Instalando dependencias de Pacman..."
sudo pacman -Syu --needed --noconfirm \
    neovim \
    git \
    base-devel \
    gcc \
    make \
    unzip \
    curl \
    gzip \
    tar \
    ripgrep \
    fd \
    fzf \
    python \
    python-pip \
    nodejs \
    npm \
    jdk-openjdk \
    clang \
    typst \
    ttf-nerd-fonts-symbols-only

if ! command -v yay &> /dev/null; then
    echo "🔍 'yay' no encontrado. Instalando yay para paquetes de AUR (ej. tinymist)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

echo "📦 Instalando herramientas de Typst desde AUR..."
yay -S --needed --noconfirm tinymist typstyle

if [ -d "$HOME/.config/nvim" ]; then
    echo "🗂️ Respaldando configuración existente en ~/.config/nvim.bak..."
    rm -rf "$HOME/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi

echo "📥 Clonando tu repositorio desde GitHub (franciscoavilaluna/nvim)..."
git clone https://github.com/franciscoavilaluna/nvim.git "$HOME/.config/nvim"

echo "⚡ Instalando y compilando plugins con Lazy.nvim..."
nvim --headless "+Lazy! sync" +qa

echo "✅ ¡Instalación completada con éxito! Ya puedes abrir Neovim ejecutando 'nvim'."
