```
███╗   ██╗██╗   ██╗██╗███╗   ███╗    ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
████╗  ██║██║   ██║██║████╗ ████║    ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██╔██╗ ██║██║   ██║██║██╔████╔██║    ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║    ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

A modular and blazing-fast **Neovim** configuration tailored for **Data Science**, **Academic Writing in Typst**, **SQL workflows** and **Full-Stack Development**.

![Neovim](https://img.shields.io/badge/Editor-Neovim_0.11+-57A143?style=for-the-badge&logo=neovim&logoColor=white)
![Linux](https://img.shields.io/badge/OS-Linux_Cross--Distro-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Lua](https://img.shields.io/badge/Configured_With-Lua-000080?style=for-the-badge&logo=lua&logoColor=white)

---

## Key Features

### UI Experience
- **Noice.nvim & nvim-notify** — floating notifications and an integrated command-line UI.
- **indent-blankline.nvim** — vertical indentation guides (`▏`) with scope highlighting.
- **lualine.nvim** — status line.
- **which-key.nvim** — on-screen hints for leader-key mappings.

### Data Science & Interactive Workflows
- **Jupytext.nvim** — open and edit `.ipynb` notebooks as plain Python scripts.
- **Quarto-nvim + otter.nvim** — run and preview `.qmd` documents, cell by cell.
- **Iron.nvim** — REPL integration (Python via `ipython`, plus shell) with per-line / per-block / per-file send.
- **venv-selector.nvim** — pick a Python virtualenv from Telescope.
- **basedpyright** (via Mason) — Python diagnostics and completion.
- Molten.nvim keymaps are pre-wired (`<leader>mi`, `<leader>e`, `<leader>rl`, `<leader>r`, `<leader>rc`, `<leader>ho`) for Jupyter kernel execution — see [Known Limitations](#known-limitations).

### Academic Writing in Typst
- **Tinymist LSP** — autocompletion for `#` functions, variables, labels and imports.
- **Typst Preview (SyncTeX)** — live PDF preview with bidirectional sync between source and PDF.
- **Typstyle** — automatic formatting for Typst markup, tables and math on save.

### SQL Workflow
- Built-in floating-window **SQL connection manager** (`<leader>db` in `.sql` files): add/select/delete connections for MariaDB, Postgres or SQLite.
- Passwords are stored in the system keyring via `secret-tool` (libsecret), never in plain text.
- Run the current line or a visual selection with `F10`; results open in a scratch split.

### Polyglot Development & Tooling
- **Mason + nvim-lspconfig** — auto-configured LSPs for Python (`pyright`/`basedpyright`), C/C++ (`clangd`), Java (`jdtls`), SQL (`sqlls`), HTML/CSS, and Typst (`tinymist`).
- **blink.cmp** — fast completion engine with Tab/S-Tab snippet-aware cycling.
- **Buffer formatter** (`<leader>f`) — dispatches to `black` (Python), `sqlformat` (SQL), `clang-format` (C/C++), `rustfmt` (Rust) or `stylua` (Lua).
- **Live PHP/HTML/CSS/JS server** — `F10` in those filetypes spins up `php -S localhost:8080` and opens it in the browser; the server is killed automatically on exit.
- **image.nvim** — inline image rendering for Markdown (via ImageMagick).

### Productivity & Navigation
- **Telescope.nvim** (+ `fzf-native`) — fuzzy file finder (`<leader>pf`), live grep (`<leader>pg`), buffer list (`<leader>pb`).
- **lazy.nvim** — plugin manager, self-bootstrapping on first launch.

---

## Requirements

The automated installer handles all of this for you, but if you're installing manually you'll need:

| Tool | Purpose |
|---|---|
| **Neovim ≥ 0.11** | Required — `lsp.lua` uses the native `vim.lsp.config`/`vim.lsp.enable` API, which doesn't exist before 0.11 |
| **git** | Cloning the config and plugins |
| **base-devel / build-essential** (gcc, make) | Building native plugin components |
| **ripgrep**, **fd** | Telescope live grep / file search |
| **unzip**, **curl**, **gzip**, **tar** | Mason package downloads |
| **Python 3 + pip** | Python tooling, `black`, `basedpyright` |
| **Node.js + npm** | Several LSPs / formatters installed via Mason |
| **A JDK** (`openjdk`) | `jdtls` (Java LSP) |
| **clang** | `clangd` and `clang-format` |
| **Rust/Cargo** | Building `tinymist` and `typstyle` (Typst LSP/formatter) |
| **Typst** | Typst compiler itself |
| **A Nerd Font** | Icons in the UI (`ttf-nerd-fonts-symbols-common` on Arch) |
| **yay** (Arch only) | AUR access, used to install `tinymist`/`typstyle` there |

Optional, only needed for specific features:
- **ImageMagick** — inline image previews (`image.nvim`)
- **libsecret / `secret-tool`** + **gnome-keyring** (or equivalent) — the SQL manager's credential storage
- **mariadb / psql / sqlite3** client binaries — whichever database engines you actually connect to
- **PHP** — the built-in local dev server for `.php`/`.html`/`.css`/`.js` files
- **stylua**, **rustfmt** — only if you use `<leader>f` on Lua/Rust files (not installed by `install.sh`)
- **pynvim + jupyter_client** (`python3 -m pip install --user pynvim jupyter_client`, then `:UpdateRemotePlugins`) — required for Molten (Jupyter kernel execution)

---

## Quick Automated Installation

`install.sh` detects your distro (Arch/Manjaro/EndeavourOS, Debian/Ubuntu/Pop/Mint, Fedora/RHEL/CentOS, or Alpine), installs every dependency above, backs up any existing config, clones this repository into `~/.config/nvim`, and syncs all plugins headlessly.

```bash
curl -fsSL https://raw.githubusercontent.com/franciscoavilaluna/nvim/main/install.sh | bash
```

What it does, step by step:
1. Detects your OS via `/etc/os-release`.
2. Installs Neovim, git, build tools, `ripgrep`, `fd`, `fzf`, Python, Node.js, a JDK and `clang` through your distro's package manager (on Arch it also bootstraps `yay` if missing, then installs `tinymist`/`typstyle` from the AUR; elsewhere it installs Rust via `rustup` and builds them with `cargo install --locked`).
3. If `~/.config/nvim` already exists, moves it to `~/.config/nvim.bak`.
4. Clones this repository into `~/.config/nvim`.
5. Runs `nvim --headless "+Lazy! sync" +qa` to install and sync all plugins non-interactively.

When it finishes, just run:

```bash
nvim
```

> Unsupported/unlisted distros fall back to a generic check for `pacman`, `apt-get` or `dnf`; if none is found, the script exits and asks you to install dependencies manually.

---

## Manual Installation

If you'd rather install by hand (or you're on a distro the script doesn't special-case):

1. **Install Neovim ≥ 0.10** and the base tools — `git`, a C compiler + `make`, `unzip`, `curl`.

   ```bash
   # Arch
   sudo pacman -Syu --needed neovim git base-devel gcc make unzip curl gzip tar \
       ripgrep fd fzf python python-pip nodejs npm openjdk-src clang typst ttf-nerd-fonts-symbols-common

   # Debian/Ubuntu
   sudo apt update && sudo apt install -y neovim git build-essential gcc make unzip curl gzip tar \
       ripgrep fd-find fzf python3 python3-pip nodejs npm default-jdk clang

   # Fedora
   sudo dnf install -y neovim git @development-tools gcc make unzip curl gzip tar \
       ripgrep fd-find fzf python3 python3-pip nodejs npm java-latest-openjdk clang

   # Alpine
   sudo apk add neovim git build-base gcc make unzip curl tar \
       ripgrep fd fzf python3 py3-pip nodejs npm openjdk17 clang cargo
   ```

2. **Install the Typst tooling** (`tinymist` LSP and `typstyle` formatter):

   - Arch: `yay -S tinymist typstyle` (installs `yay` first if you don't have it).
   - Everywhere else: install Rust via `rustup` (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`), then `cargo install --locked tinymist typstyle`.

3. **Back up any existing config**, then clone this repo into place:

   ```bash
   [ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
   git clone https://github.com/franciscoavilaluna/nvim.git "$HOME/.config/nvim"
   ```

4. **Launch Neovim.** `lazy.nvim` (the plugin manager) bootstraps itself automatically on first run and installs every plugin:

   ```bash
   nvim
   ```

   Or install everything headlessly first, without opening the UI:

   ```bash
   nvim --headless "+Lazy! sync" +qa
   ```

5. **Open Neovim again** and let Mason install the configured LSPs (`basedpyright`, `jdtls`, `clangd`, `tinymist`) automatically — this happens on startup via `mason-tool-installer`. You can also trigger it manually with `:Mason` or `:MasonToolsUpdate`.

6. **(Optional) Install feature-specific extras** as needed: `black` (Python formatting), `sqlformat` (SQL formatting), `stylua` (Lua formatting), `rustfmt` (Rust formatting), ImageMagick (inline images), `libsecret`/`secret-tool` + a keyring daemon (SQL credential storage), and `mariadb`/`psql`/`sqlite3` clients for whichever databases you connect to.

---

## Keybindings

`<leader>` is **Space**. `<localleader>` is **`\`**.

### General / Windows
| Key | Action |
|---|---|
| `<leader>lc` | Reload config |
| `<leader>pv` | Open netrw file explorer |
| `Q` | Disabled (no-op) |
| `<C-w>-` | Horizontal split |
| `<C-w>\` | Vertical split |
| `H` / `J` / `K` / `L` | Move to left/down/up/right window |
| `<C-w>p` / `<C-w>n` | Previous / next buffer |
| `<C-d>` / `<C-u>` | Scroll down/up, centered |
| `J` / `K` (visual) | Move selected lines down/up |
| `<leader>s` | Search & replace word under cursor |
| `<leader>f` | Format current buffer |

### Telescope (Files & Search)
| Key | Action |
|---|---|
| `<leader>pf` | Find files |
| `<leader>pg` | Live grep |
| `<leader>pb` | List open buffers |

### Python / Jupyter (Molten)
| Key | Action |
|---|---|
| `<leader>mi` | Initialize Jupyter kernel |
| `<leader>e` | Evaluate operator |
| `<leader>rl` | Evaluate current line |
| `<leader>r` (visual) | Evaluate visual selection |
| `<leader>rc` | Re-evaluate cell |
| `<leader>ho` | Hide output |
| `<leader>vs` | Select Python virtualenv |

### REPL (Iron.nvim)
| Key | Action |
|---|---|
| `<space>jr` / `<space>jR` | Toggle / restart REPL |
| `<space>jf` | Focus REPL |
| `<space>jh` | Hide REPL |
| `<space>js` | Send motion / visual selection |
| `<space>jl` / `<space>jp` / `<space>jf` | Send line / paragraph / file |
| `<space>jb` / `<space>jn` | Send code block / send & move to next |
| `<space>jq` | Exit REPL |

### Quarto (`.qmd` files)
| Key | Action |
|---|---|
| `<leader>ic` | Run current cell |
| `<leader>ia` | Run cell and everything above |
| `<leader>iA` | Run all cells |
| `<leader>il` | Run current line |
| `<leader>i` (visual) | Run visual range |
| `<leader>in` | Run cell and move to next |
| `<leader>ip` | Start Quarto preview |
| `<leader>ir` | Render document |

### SQL (in `.sql` buffers)
| Key | Action |
|---|---|
| `<leader>db` | Open SQL connection manager |
| `F10` (normal/visual) | Run current line / selection |

### Web Dev (`.html`, `.css`, `.js`, `.php`)
| Key | Action |
|---|---|
| `F10` | Start a local PHP server for the current file's folder and open it in the browser |

---

## Known Limitations

- `stylua` and `rustfmt` (used by `<leader>f` on Lua/Rust files) aren't installed by `install.sh` — install them separately if you need them.
- Molten additionally needs a Python provider (`pynvim` + `jupyter_client`) — see Requirements above.

---

## Uninstalling / Restoring a Backup

Both the automated and manual installs back up any pre-existing config to `~/.config/nvim.bak` (or `~/.config/nvimBACKUP`, depending on the script version) before cloning. To revert:

```bash
rm -rf ~/.config/nvim
mv ~/.config/nvim.bak ~/.config/nvim
```

To remove this configuration entirely along with cached plugin data:

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```
