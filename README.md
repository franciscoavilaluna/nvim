```
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗    ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║    ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

## Requirements

- [Neovim](https://neovim.io/) >= 0.8.0
- [Git](https://git-scm.com/) >= 2.19.0
- [NodeJs](https://nodejs.org/en)
- [NPM](https://www.npmjs.com/)
- [Unzip](https://archlinux.org/packages/extra/x86_64/unzip/) (or equivalent)
- [Curl](https://curl.se/)
- [Nerd Font](https://github.com/ryanoasis/nerd-fonts) (Optional)
- [C Compiler](https://github.com/nvim-treesitter/nvim-treesitter#requirements) for `nvim-treesitter`
- [luarocks] to install rockspecs. You can remove `rockspec` from `opts.pkg.sources` to disable this feature.
- For [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
    - live grep: [ripgrep](https://github.com/BurntSushi/ripgrep)
    - find files: [fd](https://github.com/sharkdp/fd)
- A terminal that supports true color and undercurl:
    - [Kitty](https://github.com/kovidgoyal/kitty)(Linux and Macos)
    - [Wezterm](https://github.com/wez/wezterm)(Linux, Macos & Windows)
    - [Alacritty](https://github.com/alacritty/alacritty)(Linux, Macos & Windows)
    - [iTerm2](https://iterm2.com/)(Macos)

## Installation

1. #### Run the Installation Script

   Execute the following command to download and run the installation script:

   ```bash
   curl -s https://raw.githubusercontent.com/franciscoavilaluna/nvim/main/scripts/install.sh | bash
   ```

2. #### Start Neovim

   You can now start Neovim using the following command:

   `nvim`

## Additional Notes

- #### Updating Configuration:

   To update the configuration, pull the latest changes from the repository:

  ```bash
  cd ~/.config/nvim
  git pull origin main
  ```

- #### Troubleshooting:

   If you encounter issues, ensure that all files are correctly setup and check for any plugin errors during startup.

## File Structure
You can add your custom plugin specs under `lua/plugins/` All files there will be automatically loaded by [lazy.nvim](https://github.com/folke/lazy.nvim)

```
nvim
├── init.lua
├── lazy-lock.json
└── lua
    ├── config
    │   ├── lazy.lua
    │   ├── remap.lua
    │   └── set.lua
    └── plugins
        ├── colors.lua
        ├── harpoon.lua
        ├── lsp.lua
        ├── luarocks.lua
        ├── telescope.lua
        ├── treesitter.lua
        └── undotree.lua
```

- #### Tip
    It is recommended to run `:checkhealth` after installation
