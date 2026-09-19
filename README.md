# Ultimate Neovim Setup

A modular and blazing-fast **Neovim** configuration tailored for **Data Science**, **Academic Writing in Typst** and **Full-Stack Development**.

![Neovim Preview](https://img.shields.io/badge/Editor-Neovim_0.10+-57A143?style=for-the-badge&logo=neovim&logoColor=white)
![Linux](https://img.shields.io/badge/OS-Linux_Cross--Distro-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Lua](https://img.shields.io/badge/Configured_With-Lua-000080?style=for-the-badge&logo=lua&logoColor=white)

---

## Key Features

### UI Experience
* **Noice.nvim & Nvim-Notify:** Smooth floating notifications and integrated command-line UI popups.
* **Indent Blankline:** Solid vertical indentation guides (`│`) to keep code structures readable.

### Data Science & Interactive Jupyter Workflows
* **Molten.nvim:** Native Jupyter code cell execution directly inside Neovim buffers.
* **Jupytext:** Open and edit `.ipynb` notebooks seamlessly as plain text or Python scripts (`.py`).
* **Ruff & Pyright:** Instant diagnostics, import sorting, and ultra-fast formatting for Python.

### Academic Writing in Typst
* **Tinymist LSP:** Smart autocompletion for `#` functions, variables, labels, and imports.
* **Typst Preview (SyncTeX):** Real-time live browser/PDF preview with **bidirectional synchronization** (click on the PDF to jump to the exact source line in Neovim and vice versa).
* **Typstyle:** Automatic formatting for markup code, tables, and math equations on save.

### Polyglot Development & Tooling
* **Auto-configured LSPs via Mason:** Python, C/C++ (`clangd`), Java (`jdtls`), SQL, HTML, CSS, and Typst.
* **Blink.cmp:** Blazing-fast completion engine featuring super-tab support.

### Productivity & Navigation
* **Telescope.nvim:** Fuzzy finder for files, global text search (*grep*), buffers, and diagnostics.

---

## Quick Automated Installation

Install all system dependencies, formatters, LSPs, and clone this configuration using a single command (compatible with Arch Linux, Debian/Ubuntu, Fedora, and Alpine):

```bash
curl -sS [https://raw.githubusercontent.com/franciscoavilaluna/nvim/main/install.sh](https://raw.githubusercontent.com/franciscoavilaluna/nvim/main/install.sh) | bash
