<div align="center">

```
███╗   ██╗██╗   ██╗██╗███╗   ███╗    ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
████╗  ██║██║   ██║██║████╗ ████║    ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██╔██╗ ██║██║   ██║██║██╔████╔██║    ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║    ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

### A modular, batteries-included Neovim distribution for **Data Science**, **Academic Writing** and **Polyglot Development**

*Notebooks · Jupyter · Quarto · Typst · SQL · C/C++ · Java · C# · Web · Lua/Rust tooling — under one `Space` key.*

[![Neovim](https://img.shields.io/badge/Neovim_0.11+-57A143?style=for-the-badge&logo=neovim&logoColor=white)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Configured_with-Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org)
[![Linux](https://img.shields.io/badge/Linux-Arch_%7C_Debian_%7C_Fedora_%7C_openSUSE-FCC624?style=for-the-badge&logo=linux&logoColor=black)](#requirements)
[![Plugin Manager](https://img.shields.io/badge/Plugin_manager-lazy.nvim-4B8BBE?style=for-the-badge&logo=vim&logoColor=white)](https://github.com/folke/lazy.nvim)
[![Plugins](https://img.shields.io/badge/Plugins-30%2B-orange?style=for-the-badge)](#feature-highlights)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge)](../../pulls)

</div>

---

## Table of Contents

- [Why this configuration](#why-this-configuration)
- [Feature highlights](#feature-highlights)
- [Engineering highlights](#engineering-highlights)
- [Repository layout](#repository-layout)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Automated installer](#automated-installer)
  - [Manual installation](#manual-installation)
- [First launch & post-install](#first-launch--post-install)
- [Keybindings](#keybindings)
- [Custom Lua modules](#custom-lua-modules)
- [Extending the configuration](#extending-the-configuration)
- [Health checks & troubleshooting](#health-checks--troubleshooting)
- [Known limitations](#known-limitations)
- [Uninstall / restore a backup](#uninstall--restore-a-backup)
- [Credits & acknowledgements](#credits--acknowledgements)

---

## Why this configuration

Most Neovim setups are either a 2 000-line `init.lua` or a fork of a framework you don't fully
understand. This one is deliberately different:

- **Modular by feature, not by plugin.** Every plugin lives in its own file under `lua/plugins/`
  and every cross-cutting concern (options, keymaps, autocmds, formatting, SQL) lives in a
  dedicated module. Adding or removing a capability means touching exactly one file.
- **Native where it matters.** Language servers use the built-in `vim.lsp.config` /
  `vim.lsp.enable` API (Neovim ≥ 0.11) instead of a third-party abstraction layer, so the
  configuration stays close to upstream and survives refactors.
- **Fast by default.** `lazy.nvim` loads plugins on events, commands and filetypes. Completion
  (`blink.cmp`, Rust-based core) and fuzzy search (`telescope-fzf-native`, compiled C) are chosen
  for latency, not just looks.
- **Safe with secrets.** SQL passwords are stored in the system keyring via `secret-tool`
  (libsecret) and read on demand — never written to disk in plain text.
- **Reproducible.** `install.sh` is an idempotent, distro-agnostic installer with plugins pinned
  by `lazy-lock.json`, a dry-run mode, a dependency doctor, automatic backups and a Python
  virtualenv with the Jupyter tooling wired into Neovim.

---

## Feature highlights

### Data Science & Jupyter
- **Molten.nvim** — run Python inside Neovim against a live Jupyter kernel with inline output
  rendered by `image.nvim`.
- **Jupytext.nvim** — open `.ipynb` notebooks as clean, version-controllable Python scripts.
- **Quarto + Otter** — execute and preview `.qmd` documents cell by cell, with LSP features
  (completion, diagnostics) inside Python code chunks.
- **Iron.nvim** — a persistent REPL (IPython, Bash, MATLAB) with per-line, per-block,
  per-paragraph and per-file send.
- **venv-selector.nvim** — switch between project virtualenvs straight from Telescope.
- **basedpyright** — fast, strict Python language server.

### Academic writing in Typst
- **Tinymist LSP** — completion for `#` functions, variables, labels and imports.
- **typst-preview.nvim** — live PDF preview with bidirectional SyncTeX navigation.
- **Typstyle** formatting on demand, plus `exportPdf = "onType"` for instant feedback.

### SQL workbench
- A hand-written **floating-window connection manager** (`<leader>db` in `.sql` buffers) to add,
  select and delete connections for **MariaDB**, **PostgreSQL** and **SQLite**.
- Credentials are pulled from the system keyring, and connection files are `chmod 600`.
- Run the current line or a visual selection with `F10`; results open in a read-only scratch
  buffer that closes with `q`.

### Polyglot development
- **Mason + `nvim-lspconfig`** auto-install language servers: `basedpyright`, `jdtls`, `clangd`,
  `sqlls`, `html`, `cssls`, `csharp_ls` and `tinymist`.
- **Buffer formatter** (`<leader>f`) dispatching to `black`, `sqlformat`, `clang-format`,
  `rustfmt` and `stylua`.
- **One-key runs** bound to `F10`, contextual to the filetype:
  - Web (`html`/`css`/`js`/`php`) → serve the folder with `php -S localhost:8080` and open the browser.
  - Java → compile every `.java` file in the directory with `javac`.
  - Typst → launch the live preview.
  - SQL → execute the line/selection.
- **Treesitter** highlighting, folding and indentation for 20+ languages.

### UI & navigation
- **cyberdream** colorscheme, **lualine** status line, **indent-blankline** scope guides.
- **noice.nvim** + **nvim-notify** — a floating command line and rich notifications.
- **which-key.nvim** — discoverable leader-key hints.
- **Telescope** (+ `fzf-native`) — find files, live-grep and browse buffers.
- **blink.cmp** + **LuaSnip** — snippet-aware completion with `<Tab>` / `<S-Tab>` cycling.

<!--
### Screenshots

Drop images here once captured and delete this comment block. Suggested shots:
  docs/screenshots/dashboard.png   — startup screen + lualine + which-key
  docs/screenshots/jupyter.png     — Molten inline output
  docs/screenshots/sql-manager.png — floating SQL connection manager
  docs/screenshots/typst.png       — Typst preview side by side
-->

---

## Engineering highlights

Beyond assembling plugins, this repository contains original code worth a look:

| Component | What it does | Where |
|---|---|---|
| **Custom installer** | ~900-line, dependency-free Bash installer. Auto-detects Arch/Debian/Fedora/openSUSE, resolves package names per distro, falls back to prebuilt GitHub binaries for Neovim, tree-sitter-cli, Typst, Tinymist and StyLua, provisions a Python venv, installs a Nerd Font, and supports an interactive menu, module selection, `--dry-run`, `--check` and safe config backups. | [`install.sh`](install.sh) |
| **SQL client** | A full connection manager built on nvim's floating-window API, with a keyring-backed credential flow, JSON persistence with `chmod 600`, visual-mode execution, `USE db` detection and a statusline component. | [`lua/custom/sql.lua`](lua/custom/sql.lua) |
| **Formatter dispatcher** | A single entry point that pipes the buffer through the right external formatter based on `filetype`, preserving cursor position and reporting failures through `vim.notify`. | [`lua/custom/format.lua`](lua/custom/format.lua) |
| **Native LSP wiring** | Declarative `vim.lsp.config` / `vim.lsp.enable` setup with `blink.cmp` capabilities, kept independent of `mason-lspconfig`'s automatic enabling for full control. | [`lua/plugins/lsp.lua`](lua/plugins/lsp.lua) |
| **Self-bootstrapping** | `lazy.nvim` installs itself on first launch and syncs all plugins, so a fresh clone is functional after a single `nvim`. | [`lua/config/lazy.lua`](lua/config/lazy.lua) |

---

## Repository layout

```
~/.config/nvim
├── init.lua                  # Entry point: loads config and custom modules
├── install.sh                # Multi-distro automated installer
├── lazy-lock.json            # Pinned plugin revisions (reproducible builds)
├── README.md
└── lua
    ├── config
    │   ├── lazy.lua          # lazy.nvim bootstrap + plugin spec
    │   ├── general.lua       # editor options, highlights, diagnostics
    │   ├── mappings.lua      # global keybindings
    │   └── autocmds.lua      # filetype-specific <F10> actions + SQL menu
    ├── custom
    │   ├── format.lua        # external formatter dispatcher
    │   └── sql.lua           # SQL connection manager & query runner
    └── plugins               # one file per plugin / feature
        ├── autopairs.lua         ├── lsp.lua              ├── telescope.lua
        ├── colorscheme.lua       ├── lualine.lua          ├── transparent.lua
        ├── completion.lua        ├── luasnip.lua          ├── treesitter.lua
        ├── image.lua             ├── mermaid.lua          ├── typst-preview.lua
        ├── indent.lua            ├── molten.lua           ├── venv-selector.lua
        ├── iron-nvim.lua         ├── notis-ui.lua         ├── web-devicons.lua
        ├── jupytext.lua          ├── quarto.lua           └── which-key.lua
        └── ...
```

`init.lua` in full:

```lua
require("config.lazy")
require("config.mappings")
require("config.general")
require("config.autocmds")
require("custom.format")
```

---

## Requirements

The [installer](#automated-installer) provisions all of this for you. If you prefer a manual
setup, the essentials are:

| Requirement | Why |
|---|---|
| **Neovim ≥ 0.11** (0.12+ recommended) | The LSP setup uses `vim.lsp.config`/`vim.lsp.enable`; `nvim-treesitter`'s `main` branch and `tree-sitter-cli ≥ 0.26` target recent Neovim |
| **git**, **curl**, **unzip**, **tar**, **gzip** | Cloning config/plugins and Mason downloads |
| **A C compiler + `make`** (`base-devel` / `build-essential`) | Building native plugin components |
| **ripgrep**, **fd**, **fzf** | Telescope live-grep and file search |
| **Node.js + npm** | Several language servers installed via Mason |
| **Python 3 + `python3-venv`** | Python tooling, `black`, the Molten/Jupyter runtime |
| **A JDK 21+** | `jdtls` (Java) |
| **clang / clang-format** | `clangd` and C/C++ formatting |
| **Typst + Tinymist** | Typst compilation, LSP and preview |
| **A Nerd Font** | Icons across the UI (the installer uses *JetBrainsMono Nerd Font Mono*) |

**Feature-specific extras** (all installable through `install.sh` modules):

| Extra | Needed for |
|---|---|
| ImageMagick | Inline images (`image.nvim` / Molten) |
| `libsecret` / `secret-tool` + a keyring daemon | SQL credential storage |
| `mariadb` / `psql` / `sqlite3` clients | The database engines you actually use |
| PHP + `psmisc` (`fuser`) + `xdg-utils` | The `<F10>` local web server |
| `stylua`, `rustfmt` | Formatting Lua and Rust buffers |
| `wl-clipboard` / `xclip` | System clipboard integration |

> **Terminal note:** inline images (Molten, `image.nvim`) require a terminal with the
> **kitty graphics protocol** — kitty, Ghostty or WezTerm.

---

## Installation

### Automated installer

`install.sh` is a self-contained Bash script that supports **Arch, Debian/Ubuntu, Fedora and
openSUSE**, detects your distro automatically, resolves package names per family, and backs up
any existing configuration before touching it.

**Option A — clone first, then run (recommended):**

```bash
git clone https://github.com/franciscoavilaluna/nvim.git ~/.config/nvim
cd ~/.config/nvim && ./install.sh
```

**Option B — one-liner:**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/franciscoavilaluna/nvim/main/install.sh)
```

With no arguments the installer opens an **interactive menu** (full install, custom modules,
core only, dependency check, or config-only). For scripted setups, use flags:

```bash
./install.sh --all                    # core + every module
./install.sh -d ubuntu -m python,typst,sql
./install.sh --ask                    # prompt per module
./install.sh -n --all                 # dry-run: print the plan, change nothing
./install.sh --check                  # doctor: report what's installed/missing
./install.sh --config-only            # just (re)install/update this config
```

**Available modules:** `python`, `typst`, `sql`, `web`, `java`, `cpp`, `csharp`, `lua`, `rust`,
`clipboard`, `font`.

Full flag reference:

| Flag | Description |
|---|---|
| `-a, --all` | Core + every module |
| `-m, --modules <list>` | Comma-separated modules |
| `--ask` | Ask yes/no for each module |
| `--sql-engines <list>` | `mariadb,postgres,sqlite` (default: all) |
| `--python-extras` | Also install `pnglatex` + `kaleido` |
| `--skip-core` | Assume base tools are already present |
| `-d, --distro <name>` | Force `arch`/`ubuntu`/`debian`/`fedora`/`opensuse` |
| `--config-only` | Install/update only the Neovim config |
| `--no-config` | Don't touch `~/.config/nvim` |
| `--no-sync` | Skip the headless Lazy sync |
| `--no-python-hook` | Don't patch `init.lua` with `python3_host_prog` |
| `--repo <url>` | Clone from an alternate repository |
| `-c, --check` | Verify installed dependencies |
| `-l, --list-modules` | List modules and exit |
| `-y, --yes` | Never prompt (assume yes) |
| `-n, --dry-run` | Print actions without executing |
| `-v, --version` / `-h, --help` | Version / help |

What the installer does, in order:

1. Detects your distro from `/etc/os-release` and resolves package names.
2. Installs core tools, then the packages for each selected module.
3. Ensures **Neovim** and **tree-sitter-cli** meet the minimum versions, downloading prebuilt
   binaries if your repos are too old.
4. Creates a Python virtualenv at `~/.local/share/nvim/venv` with `pynvim`, `jupyter_client`,
   `ipykernel`, `jupytext`, `black`, `sqlparse`, `cairosvg`, `plotly` and more — then wires it
   into Neovim via `vim.g.python3_host_prog`.
5. Installs (or safely updates) this config, backing up any existing one to
   `~/.config/nvim.bak.<timestamp>`.
6. Runs `nvim --headless "+Lazy! sync" +qa` to install every plugin non-interactively.

### Manual installation

1. **Install the base toolchain** for your distro:

   ```bash
   # Arch
   sudo pacman -Syu --needed neovim git base-devel ripgrep fd fzf nodejs npm \
       python python-pip clang typst ttf-nerd-fonts-symbols-common

   # Debian / Ubuntu
   sudo apt update && sudo apt install -y neovim git build-essential ripgrep fd-find fzf \
       nodejs npm python3 python3-pip python3-venv clang

   # Fedora
   sudo dnf install -y neovim git @development-tools ripgrep fd-find fzf \
       nodejs npm python3 python3-pip clang
   ```

   > On Debian/Ubuntu the `fd` binary is named `fdfind`; symlink it into `~/.local/bin/fd`.

2. **Install Typst tooling** — `tinymist` (LSP) and `typstyle` (formatter):
   ```bash
   # Arch
   yay -S tinymist typstyle
   # Other distros (or via the installer's `typst` module)
   cargo install --locked tinymist typstyle
   ```

3. **Back up an existing config and clone this repo:**
   ```bash
   [ -e "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
   git clone https://github.com/franciscoavilaluna/nvim.git "$HOME/.config/nvim"
   ```

4. **Sync plugins headlessly (optional — they also install on first launch):**
   ```bash
   nvim --headless "+Lazy! sync" +qa
   ```

5. **Launch Neovim.** `lazy.nvim` bootstraps itself, then Mason installs the configured language
   servers (`:Mason` to watch, `:MasonToolsUpdate` to retry).

---

## First launch & post-install

1. Let **Mason** finish installing language servers on first start (`:Mason`).
2. Set your terminal font to a **Nerd Font** (the installer suggests *JetBrainsMono Nerd Font Mono*).
3. For **Molten/Jupyter**, make sure the Python host is set (the installer adds this hook):
   ```lua
   local py = vim.fn.stdpath("data") .. "/venv/bin/python"
   if vim.uv.fs_stat(py) then vim.g.python3_host_prog = py end
   ```
   or install into your own environment: `pip install pynvim jupyter_client ipykernel`
   and run `:UpdateRemotePlugins`.
4. Run `:checkhealth` and `./install.sh --check` to confirm everything is green.

---

## Keybindings

`<leader>` is **`Space`** and `<localleader>` is **`\`**. Many bindings are filetype-scoped and
only appear where they make sense.

### General & windows

| Key | Action |
|---|---|
| `<leader>lc` | Reload the Neovim configuration |
| `<leader>pv` | Open the netrw explorer (tree style, 20 columns) |
| `Q` | Disabled (prevents accidental macro recording) |
| `<C-w>-` / `<C-w>\` | Horizontal / vertical split |
| `H` · `J` · `K` · `L` | Move to the left / down / up / right window |
| `<C-w>p` / `<C-w>n` | Previous / next buffer |
| `<C-d>` / `<C-u>` | Scroll down / up with the cursor centered |
| `J` / `K` (visual) | Move the selection down / up |
| `<leader>s` | Search & replace the word under the cursor |
| `<leader>f` | Format the current buffer (see [formatters](#custom-lua-modules)) |
| `<leader>d` | Show the diagnostic float for the current line |

### Files & search (Telescope)

| Key | Action |
|---|---|
| `<leader>pf` | Find files |
| `<leader>pg` | Live grep |
| `<leader>pb` | List open buffers |

### Completion & snippets

| Key | Action |
|---|---|
| `<Tab>` / `<S-Tab>` | Next / previous item, or jump a snippet placeholder |
| `<C-j>` / `<C-k>` | LuaSnip: jump forward / backward |
| `<C-e>` | Autopairs: fast-wrap the surrounding text |

### Python / Jupyter (Molten)

| Key | Action |
|---|---|
| `<leader>mi` | Initialise the Jupyter kernel |
| `<leader>e` | Evaluate a motion/operator |
| `<leader>rl` | Evaluate the current line |
| `<leader>r` (visual) | Evaluate the visual selection |
| `<leader>rc` | Re-evaluate the cell |
| `<leader>ho` | Hide the output |
| `<leader>vs` | Select a Python virtualenv |

### REPL (Iron.nvim)

| Key | Action |
|---|---|
| `<space>jr` / `<space>jR` | Toggle / restart the REPL |
| `<space>jf` / `<space>jh` | Focus / hide the REPL |
| `<space>js` | Send a motion or the visual selection |
| `<space>jl` / `<space>jp` / `<space>ju` / `<space>jm` | Send line / paragraph / until cursor / until mark |
| `<space>jb` / `<space>jn` | Send code block / send block and move to the next |
| `<space>mc` / `<space>md` | Set / remove a code mark |
| `<space>j<cr>` / `<space>j<space>` | Send carriage return / interrupt |
| `<space>jq` / `<space>kl` | Exit / clear the REPL |

### Quarto (`.qmd`)

| Key | Action |
|---|---|
| `<leader>ic` | Run the current cell |
| `<leader>ia` / `<leader>iA` | Run the cell and everything above / run all cells |
| `<leader>iR` | Run all cells of all languages |
| `<leader>il` / `<leader>i` (visual) | Run the current line / visual range |
| `<leader>in` | Run the cell and move to the next one |
| `<leader>ip` / `<leader>ir` | Start preview / render the document |

### SQL (`.sql`)

| Key | Action |
|---|---|
| `<leader>db` | Open the SQL connection manager |
| `<F10>` | Run the current line (normal) or selection (visual) |
| `q` *(in the result buffer)* | Close the results split |

### Contextual `F10` actions

| Filetype | Action |
|---|---|
| `html`, `css`, `javascript`, `php` | Start `php -S localhost:8080` in the file's folder and open it in the browser (killed on exit) |
| `java` | Compile every `.java` file in the directory with `javac` |
| `typst` | Start `typst-preview` |

---

## Custom Lua modules

### `lua/custom/format.lua` — one key, many formatters

`<leader>f` pipes the buffer through an external formatter selected by `filetype`, then restores
the cursor. Unknown filetypes are reported through `vim.notify` instead of failing silently.

```lua
local formatters = {
    sql    = "sqlformat --reindent --keywords lower --identifiers lower -",
    python = "black -q -",
    c      = "clang-format",
    cpp    = "clang-format",
    rust   = "rustfmt",
    lua    = "stylua -",
}
```

Adding a language is a one-line change; wiring it to another key is a one-line mapping.

### `lua/custom/sql.lua` — a SQL workbench built on floating windows

- **Connection manager** (`.sql` → `<leader>db`): guided floating prompts to add, select or
  delete connections for MariaDB, PostgreSQL and SQLite.
- **Secure credentials**: passwords are stored with `secret-tool store` and looked up at query
  time; the connections file lives in `stdpath("data")/sql_vault/` with `chmod 600`.
- **Query execution**: `F10` runs the current line or the visual selection, detects `USE db`
  statements to switch the active database, and prints results into a read-only
  `__SQL_Result__` split.
- **Statusline component**: exposes the active connection, database and user, with a warning
  highlight for `root`.

> The module is loaded lazily through a `FileType sql` autocommand, so it costs nothing until you
> open a `.sql` file.

---

## Extending the configuration

**Add a plugin** — drop a new file in `lua/plugins/`, for example `lua/plugins/harpoon.lua`:

```lua
return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require("harpoon").setup() end,
}
```

`lazy.nvim` discovers it automatically on the next start.

**Add a language server** — add an entry to the `servers` table in `lua/plugins/lsp.lua` and list
it under `ensure_installed` in the Mason block. The `capabilities` from `blink.cmp` are applied
for you.

**Add a formatter** — add a `filetype = "command"` entry to the `formatters` table shown above.

**Change options or mappings** — `lua/config/general.lua` and `lua/config/mappings.lua`.

---

## Health checks & troubleshooting

| Command | Purpose |
|---|---|
| `./install.sh --check` | Non-destructive doctor for system dependencies |
| `:checkhealth` | Neovim's built-in diagnostics |
| `:Lazy` | Plugin manager UI — install, update, sync, profile |
| `:Mason` | Manage/install language servers, formatters and linters |
| `:MasonToolsUpdate` | Re-run the automatic install of the configured tools |
| `:TSUpdate` | Update Treesitter parsers |
| `:Lazy sync` | Reconcile plugins with `lazy-lock.json` |

**Common issues**

- *Icons look like boxes* → switch your terminal font to a Nerd Font and restart it.
- *Inline images don't render* → use kitty, Ghostty or WezTerm (kitty graphics protocol).
- *SQL asks for a password that isn't found* → make sure a Secret Service daemon
  (gnome-keyring, KeePassXC, …) is running and that `secret-tool` is on `PATH`.
- *`fd` not found on Debian/Ubuntu* → the binary is `fdfind`; symlink it to `~/.local/bin/fd`.
- *A language server isn't starting* → open `:Mason`, install it, then `:LspInfo`.

---

## Known limitations

- Inline images and the Molten output require a **kitty-graphics terminal**.
- The SQL `F10` runner shells out to the `mariadb`/`psql`/`sqlite3` client binaries; the
  password for PostgreSQL/MariaDB is passed through the shell for this call.
- `install.sh` downloads **x86_64** prebuilt binaries as a fallback; other architectures must
  install Neovim/Typst/Tinymist/StyLua through their package manager or from source.
- Fedora and openSUSE support in the installer is marked **experimental** — missing packages are
  skipped with a warning; run `--check` afterwards.

---

## Uninstall / restore a backup

The installer backs up any previous configuration to `~/.config/nvim.bak.<timestamp>` before
cloning. To restore it:

```bash
rm -rf ~/.config/nvim
mv ~/.config/nvim.bak.<timestamp> ~/.config/nvim
```

To remove this configuration and all cached plugin data entirely:

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

---

## Credits & acknowledgements

Built on the shoulders of the Neovim community — in particular
[folke](https://github.com/folke) (`lazy.nvim`, `noice.nvim`, `which-key.nvim`),
[saghen](https://github.com/Saghen) (`blink.cmp`), the
[Telescope](https://github.com/nvim-telescope) team,
[williamboman](https://github.com/williamboman) (`mason.nvim`),
[benlubas](https://github.com/benlubas) (`molten-nvim`),
[quarto-dev](https://github.com/quarto-dev) (`quarto-nvim`),
[chomosuke](https://github.com/chomosuke) (`typst-preview.nvim`) and every plugin author listed
in [`lazy-lock.json`](lazy-lock.json).

<!-- Add a LICENSE (e.g. MIT) and state the terms here before publishing. -->

<div align="center">

*If this configuration taught you something or saved you time, consider starring the repo.* ⭐

</div>
