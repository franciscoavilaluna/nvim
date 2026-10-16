#!/usr/bin/env bash
#
# install.sh - dependency + config installer for franciscoavilaluna/nvim
#
#   ./install.sh                    interactive menu
#   ./install.sh --help             all flags
#
# Design notes
#   * Everything user-level goes to ~/.local (bin, opt) and the Neovim data dir.
#     sudo is only used for the system package manager.
#   * Package names are resolved per distro; unavailable names are skipped with a
#     warning instead of aborting the whole transaction.
#   * Prebuilt GitHub binaries (Neovim, tree-sitter, typst, tinymist, stylua) are
#     used when distro packages are missing or too old. x86_64 only.
#
set -Eeuo pipefail
shopt -s inherit_errexit 2>/dev/null || true

SCRIPT_VERSION="1.0.0"
REPO_URL="https://github.com/franciscoavilaluna/nvim.git"
MIN_NVIM="0.12.0"
MIN_TS="0.26.1"
GH="https://github.com"

BIN_DIR="$HOME/.local/bin"
OPT_DIR="$HOME/.local/opt"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
NVIM_CONFIG="$CONFIG_HOME/nvim"
VENV_DIR="$DATA_HOME/nvim/venv"
TTY_DEV="${NVIM_SETUP_TTY:-/dev/tty}"

# OUTPUT HELPERS
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_BLUE=$'\033[34m'; C_DIM=$'\033[2m'
else
  C_RESET=""; C_BOLD=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_DIM=""
fi

info()    { printf '%s==>%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()      { printf '%s ok%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn()    { printf '%swarn%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()     { printf '%s err%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
die()     { err "$*"; exit 1; }
section() { printf '\n%s%s%s\n' "$C_BOLD" "$*" "$C_RESET"; }
dry()     { printf '%s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"; }

# STATE (overridden by flags)
ACTION=""
FAMILY=""
DISTRO_ID=""
ASSUME_YES=0
DRY_RUN=0
ASK_MODULES=0
ALL_MODULES=0
SKIP_CORE=0
NO_CONFIG=0
NO_SYNC=0
NO_PY_HOOK=0
PY_EXTRAS=0
SQL_ENGINES="mariadb,postgres,sqlite"
MODULES_ARG=""
SELECTED=()
PKG_SPECS=()
APT_UPDATED=0
HAVE_TTY=0
TMP_DIR=""

MODULE_ORDER=(python typst sql web java cpp csharp lua rust clipboard font)
declare -A MOD_DESC=(
  [python]="Python/Jupyter: Molten, Jupytext, Iron (dedicated venv + ImageMagick)"
  [typst]="Typst: compiler + tinymist LSP (live preview needs a browser)"
  [sql]="SQL: secret-tool + keyring, database clients, sqlformat"
  [web]="Web dev: php, psmisc (fuser), xdg-utils for the F10 live server"
  [java]="Java: JDK 21+ (jdtls, javac)"
  [cpp]="C/C++: clang + clang-format"
  [csharp]="C#: .NET SDK (csharp_ls)"
  [lua]="Lua: stylua formatter"
  [rust]="Rust: rustfmt formatter"
  [clipboard]="Clipboard: wl-clipboard (Wayland) / xclip (X11)"
  [font]="JetBrainsMono Nerd Font Mono (per-user install)"
)

cleanup() { if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then rm -rf "$TMP_DIR"; fi; }
trap cleanup EXIT
trap 'rc=$?; err "Failed at line $LINENO (exit $rc)"' ERR

SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
else
  SCRIPT_DIR=""
fi

# HELP
usage() {
  cat <<EOF
nvim setup installer v$SCRIPT_VERSION

USAGE
  install.sh                         Interactive menu
  install.sh [flags]

DISTRO
  -d, --distro <name>      arch | ubuntu | debian | fedora | opensuse
                           (default: auto-detect from /etc/os-release)
                           fedora and opensuse are EXPERIMENTAL: their package
                           names are unverified; missing ones are skipped.

WHAT TO INSTALL
  -m, --modules <list>     Comma-separated modules (see --list-modules)
  -a, --all                Core + every module
      --ask                Ask yes/no for each module
      --sql-engines <l>    With the sql module: mariadb,postgres,sqlite
                           (default: all three)
      --python-extras      With the python module: also pnglatex + kaleido
                           (kaleido 1.x needs Chrome/Chromium installed)
      --skip-core          Assume the base tools are already installed
  -l, --list-modules       List modules and exit

CONFIG
      --repo <url>         Repo to clone (default: $REPO_URL)
      --config-only        Only install/update the Neovim config
      --no-config          Do not touch ~/.config/nvim
      --no-sync            Do not run the headless Lazy sync
      --no-python-hook     Do not add the python3_host_prog hook to init.lua

OTHER
  -c, --check              Verify which dependencies are installed
  -y, --yes                Never prompt (assume yes)
  -n, --dry-run            Print what would be done, change nothing
  -v, --version            Print version
  -h, --help               This help

EXAMPLES
  install.sh --all
  install.sh -d ubuntu -m python,typst,sql
  install.sh --ask
  install.sh -d fedora --all --dry-run
  install.sh --check
EOF
}

list_modules() {
  local m
  printf 'core        Always installed (unless --skip-core): Neovim %s+, tree-sitter-cli %s+,\n' "$MIN_NVIM" "$MIN_TS"
  printf '            git, curl, wget, unzip, tar, gzip, compiler, ripgrep, fd, node/npm, python3\n'
  for m in "${MODULE_ORDER[@]}"; do
    printf '%-11s %s\n' "$m" "${MOD_DESC[$m]}"
  done
}

# GENERIC HELPERS
have() { command -v "$1" >/dev/null 2>&1; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '%s[dry-run]%s' "$C_DIM" "$C_RESET"
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    run "$@"
  else
    if [ "$DRY_RUN" -eq 0 ] && ! have sudo; then
      die "sudo is required to install system packages (or run as root)."
    fi
    run sudo "$@"
  fi
}

# a >= b ?
ver_ge() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]; }

get_nvim_version() {
  if have nvim; then nvim --version 2>/dev/null | sed -nE '1s/^NVIM v([0-9]+(\.[0-9]+)*).*/\1/p'; fi
}
get_ts_version() {
  if have tree-sitter; then tree-sitter --version 2>/dev/null | sed -nE '1s/^tree-sitter ([0-9]+(\.[0-9]+)*).*/\1/p'; fi
}

need_x86_64() {
  case "$(uname -m)" in
    x86_64|amd64) return 0 ;;
    *) warn "Prebuilt binaries are only wired up for x86_64 (this machine: $(uname -m)). Install $1 manually."
       return 1 ;;
  esac
}

# TTY HANDLING
init_tty() {
  if ( : <"$TTY_DEV" ) 2>/dev/null; then
    exec 3<"$TTY_DEV"
    HAVE_TTY=1
  fi
}

# PROMPT "text" VARNAME
prompt() {
  local __ans=""
  printf '%s' "$1" >&2
  if ! read -r -u 3 __ans; then
    printf '\n' >&2
    __ans="q"
  fi
  printf -v "$2" '%s' "$__ans"
}

# CONFIRM
confirm() {
  local q="$1" def="${2:-Y}" ans hint
  if [ "$ASSUME_YES" -eq 1 ] || [ "$HAVE_TTY" -eq 0 ]; then return 0; fi
  if [ "$def" = "Y" ]; then hint="[Y/n]"; else hint="[y/N]"; fi
  prompt "$q $hint " ans
  ans="${ans:-$def}"
  case "$ans" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

# DISTRO DETECTION
detect_family() {
  local id="" like="" line=""
  if [ -r /etc/os-release ]; then
    line="$( . /etc/os-release; printf '%s|%s' "${ID:-}" "${ID_LIKE:-}" )"
    id="${line%%|*}"; like="${line#*|}"
  fi
  DISTRO_ID="$id"
  case " $id $like " in
    *" arch "*|*" manjaro "*|*" endeavouros "*|*" cachyos "*) echo arch ;;
    *" ubuntu "*|*" debian "*|*" linuxmint "*|*" pop "*)      echo debian ;;
    *" fedora "*|*" rhel "*)                                  echo fedora ;;
    *" opensuse"*|*" suse "*|*" sles "*)                      echo opensuse ;;
    *) echo "" ;;
  esac
}

normalize_family() {
  case "$1" in
    arch|manjaro|endeavouros|cachyos) echo arch ;;
    ubuntu|debian|mint|linuxmint|pop) echo debian ;;
    fedora)                           echo fedora ;;
    opensuse|suse|tumbleweed|leap)    echo opensuse ;;
    *) echo "" ;;
  esac
}

pm_binary() {
  case "$FAMILY" in
    arch) echo pacman ;; debian) echo apt-get ;; fedora) echo dnf ;; opensuse) echo zypper ;;
  esac
}

pm_available() { have "$(pm_binary)"; }

pkg_exists() {
  case "$FAMILY" in
    arch)     pacman -Si "$1" >/dev/null 2>&1 || pacman -Qi "$1" >/dev/null 2>&1 ;;
    debian)   apt-cache show "$1" >/dev/null 2>&1 ;;
    fedora)   dnf -q list "$1" >/dev/null 2>&1 ;;
    opensuse) zypper -n -q info "$1" 2>/dev/null | grep -q '^Name' ;;
  esac
}

install_pkgs() {
  local spec cand chosen cands
  local resolved=() missing=()
  if [ "$#" -eq 0 ]; then return 0; fi

  if [ "$FAMILY" = "debian" ] && [ "$APT_UPDATED" -eq 0 ] && pm_available; then
    info "Refreshing apt package lists"
    as_root apt-get update
    APT_UPDATED=1
  fi

  for spec in "$@"; do
    chosen=""
    IFS='|' read -r -a cands <<<"$spec"
    for cand in "${cands[@]}"; do
      if ! pm_available; then
        chosen="${cands[0]}"; break
      fi
      if pkg_exists "$cand"; then chosen="$cand"; break; fi
    done
    if [ -n "$chosen" ]; then resolved+=("$chosen"); else missing+=("$spec"); fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    warn "Not available in your repositories (skipped): ${missing[*]}"
  fi
  if [ "${#resolved[@]}" -eq 0 ]; then return 0; fi

  info "Installing ${#resolved[@]} package(s): ${resolved[*]}"
  case "$FAMILY" in
    arch)
      if [ "$ASSUME_YES" -eq 1 ]; then as_root pacman -S --needed --noconfirm "${resolved[@]}"
      else as_root pacman -S --needed "${resolved[@]}"; fi ;;
    debian)
      if [ "$ASSUME_YES" -eq 1 ]; then as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${resolved[@]}"
      else as_root apt-get install "${resolved[@]}"; fi ;;
    fedora)
      if [ "$ASSUME_YES" -eq 1 ]; then as_root dnf install -y "${resolved[@]}"
      else as_root dnf install "${resolved[@]}"; fi ;;
    opensuse)
      if [ "$ASSUME_YES" -eq 1 ]; then as_root zypper --non-interactive install "${resolved[@]}"
      else as_root zypper install "${resolved[@]}"; fi ;;
  esac
}

# PACKAGE TABLES
core_pkgs() {
  case "$FAMILY" in
    arch)     echo "git curl wget unzip tar gzip base-devel ripgrep fd nodejs npm python python-pip neovim tree-sitter-cli" ;;
    debian)   echo "git curl wget unzip tar gzip build-essential ripgrep fd-find nodejs npm python3 python3-pip python3-venv" ;;
    fedora)   echo "git curl wget unzip tar gzip gcc gcc-c++ make ripgrep fd-find nodejs npm python3 python3-pip" ;;
    opensuse) echo "git curl wget unzip tar gzip gcc gcc-c++ make ripgrep fd nodejs-default|nodejs22|nodejs npm-default|npm22|npm python3 python3-pip" ;;
  esac
}

module_pkgs() {
  local m="$1" e
  case "$m:$FAMILY" in
    python:arch)       echo "python python-pip imagemagick cairo" ;;
    python:debian)     echo "python3 python3-pip python3-venv imagemagick libcairo2" ;;
    python:fedora)     echo "python3 python3-pip ImageMagick cairo" ;;
    python:opensuse)   echo "python3 python3-pip imagemagick|ImageMagick libcairo2|cairo" ;;

    typst:arch)        echo "typst tinymist" ;;
    typst:debian)      echo "xz-utils" ;;
    typst:fedora)      echo "xz" ;;
    typst:opensuse)    echo "xz" ;;

    sql:*)
      case "$FAMILY" in
        arch)     echo "libsecret gnome-keyring" ;;
        debian)   echo "libsecret-tools gnome-keyring" ;;
        fedora)   echo "libsecret gnome-keyring" ;;
        opensuse) echo "libsecret-tools|libsecret gnome-keyring" ;;
      esac
      for e in ${SQL_ENGINES//,/ }; do sql_engine_pkgs "$e"; done ;;

    web:arch)          echo "php psmisc xdg-utils" ;;
    web:debian)        echo "php-cli psmisc xdg-utils" ;;
    web:fedora)        echo "php-cli psmisc xdg-utils" ;;
    web:opensuse)      echo "php8-cli|php-cli|php8 psmisc xdg-utils" ;;

    java:arch)         echo "jdk-openjdk" ;;
    java:debian)       echo "openjdk-21-jdk|openjdk-25-jdk|default-jdk" ;;
    java:fedora)       echo "java-21-openjdk-devel|java-latest-openjdk-devel" ;;
    java:opensuse)     echo "java-21-openjdk-devel|java-25-openjdk-devel|java-17-openjdk-devel" ;;

    cpp:arch)          echo "clang" ;;
    cpp:debian)        echo "clang clang-format" ;;
    cpp:fedora)        echo "clang clang-tools-extra" ;;
    cpp:opensuse)      echo "clang clang-tools|clang" ;;

    csharp:arch)       echo "dotnet-sdk" ;;
    csharp:*)          echo "dotnet-sdk-10.0|dotnet-sdk-9.0|dotnet-sdk-8.0" ;;

    rust:arch)         echo "rust" ;;
    rust:opensuse)     echo "rustfmt|rust" ;;
    rust:*)            echo "rustfmt" ;;

    lua:arch)          echo "stylua" ;;
    font:*)            echo "fontconfig" ;;
    clipboard:*)       clipboard_pkgs ;;
    *)                 echo "" ;;
  esac
}

sql_engine_pkgs() {
  case "$1:$FAMILY" in
    mariadb:arch)      echo "mariadb-clients|mariadb" ;;
    mariadb:debian)    echo "mariadb-client" ;;
    mariadb:fedora)    echo "mariadb|mariadb-client" ;;
    mariadb:opensuse)  echo "mariadb-client" ;;
    postgres:arch)     echo "postgresql" ;;
    postgres:debian)   echo "postgresql-client" ;;
    postgres:*)        echo "postgresql" ;;
    sqlite:arch)       echo "sqlite" ;;
    sqlite:debian)     echo "sqlite3" ;;
    sqlite:fedora)     echo "sqlite" ;;
    sqlite:opensuse)   echo "sqlite3" ;;
  esac
}

clipboard_pkgs() {
  if [ -n "${WAYLAND_DISPLAY:-}" ] || [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    echo "wl-clipboard"
  elif [ -n "${DISPLAY:-}" ]; then
    echo "xclip"
  else
    echo "wl-clipboard xclip"
  fi
}

has_module() {
  local m
  if [ "${#SELECTED[@]}" -eq 0 ]; then return 1; fi
  for m in "${SELECTED[@]}"; do if [ "$m" = "$1" ]; then return 0; fi; done
  return 1
}

# GIThUB BINARY INSTALLERS (X86_64)
ensure_tmp() { if [ -z "$TMP_DIR" ]; then TMP_DIR="$(mktemp -d)"; fi; }

fetch() {
  curl -fL --retry 3 --retry-delay 2 -sS -o "$2" "$1"
}

install_neovim_github() {
  need_x86_64 "Neovim" || return 0
  info "Installing Neovim (latest stable) from GitHub"
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "download neovim nvim-linux-x86_64.tar.gz -> $OPT_DIR, link $BIN_DIR/nvim"; return 0
  fi
  ensure_tmp; mkdir -p "$BIN_DIR" "$OPT_DIR"
  fetch "$GH/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" "$TMP_DIR/nvim.tar.gz"
  rm -rf "$OPT_DIR/nvim-linux-x86_64"
  tar -xzf "$TMP_DIR/nvim.tar.gz" -C "$OPT_DIR"
  ln -sf "$OPT_DIR/nvim-linux-x86_64/bin/nvim" "$BIN_DIR/nvim"
}

install_treesitter_github() {
  need_x86_64 "tree-sitter-cli" || return 0
  info "Installing tree-sitter-cli from GitHub"
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "download tree-sitter-linux-x64.gz -> $BIN_DIR/tree-sitter"; return 0
  fi
  ensure_tmp; mkdir -p "$BIN_DIR"
  fetch "$GH/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz" "$TMP_DIR/ts.gz"
  gunzip -c "$TMP_DIR/ts.gz" > "$BIN_DIR/tree-sitter"
  chmod +x "$BIN_DIR/tree-sitter"
}

install_typst_github() {
  need_x86_64 "typst" || return 0
  info "Installing typst from GitHub"
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "download typst-x86_64-unknown-linux-musl.tar.xz -> $BIN_DIR/typst"; return 0
  fi
  have xz || die "xz is required to unpack typst (install xz / xz-utils)."
  ensure_tmp; mkdir -p "$BIN_DIR"
  fetch "$GH/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz" "$TMP_DIR/typst.tar.xz"
  tar -xJf "$TMP_DIR/typst.tar.xz" -C "$TMP_DIR"
  install -m 0755 "$TMP_DIR/typst-x86_64-unknown-linux-musl/typst" "$BIN_DIR/typst"
}

install_tinymist_github() {
  need_x86_64 "tinymist" || return 0
  info "Installing tinymist from GitHub"
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "download tinymist-linux-x64 -> $BIN_DIR/tinymist"; return 0
  fi
  ensure_tmp; mkdir -p "$BIN_DIR"
  fetch "$GH/Myriad-Dreamin/tinymist/releases/latest/download/tinymist-linux-x64" "$TMP_DIR/tinymist"
  install -m 0755 "$TMP_DIR/tinymist" "$BIN_DIR/tinymist"
}

install_stylua_github() {
  need_x86_64 "stylua" || return 0
  info "Installing stylua from GitHub"
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "download stylua-linux-x86_64.zip -> $BIN_DIR/stylua"; return 0
  fi
  ensure_tmp; mkdir -p "$BIN_DIR"
  fetch "$GH/JohnnyMorganz/StyLua/releases/latest/download/stylua-linux-x86_64.zip" "$TMP_DIR/stylua.zip"
  unzip -o -q "$TMP_DIR/stylua.zip" stylua -d "$TMP_DIR"
  install -m 0755 "$TMP_DIR/stylua" "$BIN_DIR/stylua"
}

install_font_github() {
  info "Installing JetBrainsMono Nerd Font Mono (~40 MB) into ~/.local/share/fonts"
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "download JetBrainsMono.zip, extract JetBrainsMonoNerdFontMono-*.ttf, fc-cache"; return 0
  fi
  ensure_tmp; mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNF"
  fetch "$GH/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "$TMP_DIR/jb.zip"
  unzip -o -q "$TMP_DIR/jb.zip" 'JetBrainsMonoNerdFontMono-*.ttf' 'OFL.txt' -d "$HOME/.local/share/fonts/JetBrainsMonoNF"
  if have fc-cache; then fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true; fi
}

# POST INSTALL
ensure_neovim() {
  local v; v="$(get_nvim_version || true)"
  if [ -n "$v" ] && ver_ge "$v" "$MIN_NVIM"; then ok "Neovim $v"; return 0; fi
  if [ -n "$v" ]; then warn "Neovim $v is older than $MIN_NVIM (needed by nvim-treesitter main)"; fi
  install_neovim_github
}

ensure_treesitter() {
  local v; v="$(get_ts_version || true)"
  if [ -n "$v" ] && ver_ge "$v" "$MIN_TS"; then ok "tree-sitter-cli $v"; return 0; fi
  if [ -n "$v" ]; then warn "tree-sitter-cli $v is older than $MIN_TS"; fi
  install_treesitter_github
}

link_tool() { # link_tool name  (venv/bin/name -> ~/.local/bin/name)
  local name="$1" src="$VENV_DIR/bin/$1" dst="$BIN_DIR/$1"
  if [ "$DRY_RUN" -eq 1 ]; then dry "link $dst -> $src"; return 0; fi
  [ -e "$src" ] || return 0
  mkdir -p "$BIN_DIR"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "$dst exists and is not a symlink; leaving it alone"; return 0
  fi
  if [ -L "$dst" ] && [ "$(readlink "$dst")" != "$src" ]; then
    warn "$dst already points elsewhere ($(readlink "$dst")); leaving it alone"; return 0
  fi
  ln -sf "$src" "$dst"
}

ensure_venv() {
  if [ -x "$VENV_DIR/bin/python" ]; then ok "Neovim Python venv exists ($VENV_DIR)"; return 0; fi
  have python3 || [ "$DRY_RUN" -eq 1 ] || die "python3 not found"
  info "Creating Neovim Python venv at $VENV_DIR"
  run mkdir -p "$(dirname "$VENV_DIR")"
  if ! run python3 -m venv "$VENV_DIR"; then
    die "python3 -m venv failed. On Debian/Ubuntu install python3-venv."
  fi
  run "$VENV_DIR/bin/python" -m pip install --quiet --upgrade pip
}

venv_pip() { run "$VENV_DIR/bin/python" -m pip install --quiet "$@"; }

PY_HOOK_LUA='-- Neovim-managed Python host (added by install.sh)
do
  local py = vim.fn.stdpath("data") .. "/venv/bin/python"
  if vim.uv.fs_stat(py) then vim.g.python3_host_prog = py end
end
'

python_hook_present() { grep -rqs --include='*.lua' 'python3_host_prog' "$NVIM_CONFIG/" 2>/dev/null; }

patch_python_hook() {
  local init="$NVIM_CONFIG/init.lua" tmp
  if [ "$NO_PY_HOOK" -eq 1 ]; then return 0; fi
  if [ "$DRY_RUN" -eq 1 ]; then dry "add python3_host_prog hook to $init (if missing)"; return 0; fi
  if [ ! -f "$init" ]; then
    warn "No $init found; add this to your config yourself:"; printf '%s\n' "$PY_HOOK_LUA"; return 0
  fi
  if python_hook_present; then ok "python3_host_prog already set in your config"; return 0; fi
  if ! confirm "Add a python3_host_prog hook to $init (points Neovim at the venv)?" Y; then
    warn "Skipped. Add this near the top of init.lua:"; printf '%s\n' "$PY_HOOK_LUA"; return 0
  fi
  tmp="$(mktemp)"
  { printf '%s\n' "$PY_HOOK_LUA"; cat "$init"; } > "$tmp"
  cat "$tmp" > "$init"; rm -f "$tmp"
  ok "Hook added to $init (remember to commit it to your repo)"
}

post_python() {
  local pkgs=(pynvim jupyter_client ipykernel nbformat cairosvg plotly pyperclip jupytext black ipython)
  ensure_venv
  info "Installing Python packages into the venv"
  if [ "$PY_EXTRAS" -eq 1 ]; then pkgs+=(pnglatex kaleido); fi
  venv_pip "${pkgs[@]}"
  run "$VENV_DIR/bin/python" -m ipykernel install --user --name nvim-python --display-name "Python (nvim)"
  link_tool jupytext
  link_tool black
  if ! have ipython; then link_tool ipython; fi
  patch_python_hook
}

post_typst() {
  if [ "$FAMILY" != "arch" ]; then
    if have typst; then ok "typst already installed"; else install_typst_github; fi
    if have tinymist; then ok "tinymist already installed"; else install_tinymist_github; fi
  fi
}

post_sql() {
  ensure_venv
  venv_pip sqlparse
  link_tool sqlformat
  warn "SQL passwords go through secret-tool: you need a running Secret Service (gnome-keyring, KeePassXC, ...)."
}

post_csharp() {
  if ! have dotnet && [ "$DRY_RUN" -eq 0 ]; then
    warn "No .NET SDK package was found for your distro. Debian ships none in its main repos;"
    warn "see https://learn.microsoft.com/dotnet/core/install/linux (needed only for csharp_ls)."
  fi
}

post_lua() {
  if [ "$FAMILY" != "arch" ]; then
    if have stylua; then ok "stylua already installed"; else install_stylua_github; fi
  fi
}

post_font() {
  if [ "$DRY_RUN" -eq 0 ] && have fc-list && fc-list 2>/dev/null | grep -qi 'JetBrainsMono.*Nerd'; then
    ok "JetBrainsMono Nerd Font already installed"
  else
    install_font_github
  fi
}

post_cpp() {
  if [ "$DRY_RUN" -eq 0 ] && ! have clang-format; then
    warn "clang-format not found after install; <leader>f will not work for C/C++."
  fi
}

post_core() {
  ensure_neovim
  ensure_treesitter
  # Debian/Ubuntu name the binary "fdfind"; venv-selector looks for "fd".
  if [ "$DRY_RUN" -eq 1 ]; then
    if [ "$FAMILY" = "debian" ]; then dry "link $BIN_DIR/fd -> fdfind"; fi
  elif ! have fd && have fdfind; then
    mkdir -p "$BIN_DIR"; ln -sf "$(command -v fdfind)" "$BIN_DIR/fd"
    ok "Linked fd -> fdfind"
  fi
}

# NEOVIM CONFIG (CLONE OR LINK) + PLUGIN SYNC
same_path() { [ "$(readlink -f "$1" 2>/dev/null)" = "$(readlink -f "$2" 2>/dev/null)" ]; }

backup_config() {
  local dst="$NVIM_CONFIG.bak.$(date +%Y%m%d-%H%M%S)"
  info "Backing up existing config to $dst"
  run mv "$NVIM_CONFIG" "$dst"
}

install_config() {
  have git || [ "$DRY_RUN" -eq 1 ] || die "git is required"
  run mkdir -p "$CONFIG_HOME"

  if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/init.lua" ] && [ -d "$SCRIPT_DIR/lua" ]; then
    if [ -e "$NVIM_CONFIG" ] && same_path "$NVIM_CONFIG" "$SCRIPT_DIR"; then
      ok "Config already in place ($NVIM_CONFIG)"; return 0
    fi
    if confirm "Link $NVIM_CONFIG -> $SCRIPT_DIR ?" Y; then
      if [ -e "$NVIM_CONFIG" ] || [ -L "$NVIM_CONFIG" ]; then backup_config; fi
      run ln -s "$SCRIPT_DIR" "$NVIM_CONFIG"
      return 0
    fi
  fi

  if [ -d "$NVIM_CONFIG/.git" ]; then
    local origin; origin="$(git -C "$NVIM_CONFIG" remote get-url origin 2>/dev/null || true)"
    if [ "${origin%.git}" = "${REPO_URL%.git}" ]; then
      info "Updating existing clone in $NVIM_CONFIG"
      run git -C "$NVIM_CONFIG" pull --ff-only || warn "git pull failed (local changes?); leaving the config as is"
      return 0
    fi
  fi

  if [ -e "$NVIM_CONFIG" ] || [ -L "$NVIM_CONFIG" ]; then backup_config; fi
  info "Cloning $REPO_URL"
  run git clone "$REPO_URL" "$NVIM_CONFIG"
}

sync_plugins() {
  if [ "$NO_SYNC" -eq 1 ]; then return 0; fi
  if [ "$DRY_RUN" -eq 0 ] && ! have nvim; then warn "nvim not found in PATH; skipping plugin sync"; return 0; fi
  if [ "$DRY_RUN" -eq 0 ] && [ ! -f "$NVIM_CONFIG/init.lua" ]; then warn "No config at $NVIM_CONFIG; skipping plugin sync"; return 0; fi
  info "Syncing plugins with lazy.nvim (headless, can take a few minutes)"
  run nvim --headless "+Lazy! sync" +qa || warn "Lazy sync reported errors; open nvim and run :Lazy"
  if has_module python; then
    run nvim --headless "+UpdateRemotePlugins" +qa || warn "UpdateRemotePlugins failed; run it manually inside nvim"
  fi
}

# DOCTOR
chk() {
  if have "$2"; then
    printf '  %s✓%s %-16s %s\n' "$C_GREEN" "$C_RESET" "$1" "$(command -v "$2")"; return 0
  else
    printf '  %s✗%s %-16s missing%s\n' "$C_RED" "$C_RESET" "$1" "${3:+ ($3)}"; return 1
  fi
}

doctor() {
  local bad=0 v
  info "Checking dependencies (read-only)"
  section "core"
  v="$(get_nvim_version || true)"
  if [ -n "$v" ] && ver_ge "$v" "$MIN_NVIM"; then printf '  %s✓%s %-16s %s\n' "$C_GREEN" "$C_RESET" "neovim" "$v"
  else printf '  %s✗%s %-16s %s (need >= %s)\n' "$C_RED" "$C_RESET" "neovim" "${v:-missing}" "$MIN_NVIM"; bad=$((bad+1)); fi
  v="$(get_ts_version || true)"
  if [ -n "$v" ] && ver_ge "$v" "$MIN_TS"; then printf '  %s✓%s %-16s %s\n' "$C_GREEN" "$C_RESET" "tree-sitter" "$v"
  else printf '  %s✗%s %-16s %s (need >= %s)\n' "$C_RED" "$C_RESET" "tree-sitter" "${v:-missing}" "$MIN_TS"; bad=$((bad+1)); fi
  chk git git || bad=$((bad+1))
  chk curl curl || bad=$((bad+1))
  chk unzip unzip || bad=$((bad+1))
  chk tar tar || bad=$((bad+1))
  chk gcc gcc || bad=$((bad+1))
  chk make make || bad=$((bad+1))
  chk ripgrep rg || bad=$((bad+1))
  chk fd fd "on Debian/Ubuntu: ln -s \$(which fdfind) ~/.local/bin/fd" || bad=$((bad+1))
  chk node node || bad=$((bad+1))
  chk npm npm || bad=$((bad+1))
  chk python3 python3 || bad=$((bad+1))

  section "python"
  if [ -x "$VENV_DIR/bin/python" ] && "$VENV_DIR/bin/python" -c 'import pynvim, jupyter_client, ipykernel' 2>/dev/null; then
    printf '  %s✓%s %-16s %s\n' "$C_GREEN" "$C_RESET" "nvim venv" "$VENV_DIR"
  else
    printf '  %s✗%s %-16s missing or incomplete (%s)\n' "$C_RED" "$C_RESET" "nvim venv" "$VENV_DIR"
  fi
  if [ -d "$NVIM_CONFIG" ] && python_hook_present; then
    printf '  %s✓%s %-16s set in config\n' "$C_GREEN" "$C_RESET" "python3_host_prog"
  else
    printf '  %s✗%s %-16s not set in config\n' "$C_RED" "$C_RESET" "python3_host_prog"
  fi
  chk jupytext jupytext || true
  chk black black || true
  chk ipython ipython "install it inside each project venv" || true
  if have magick || have convert; then printf '  %s✓%s %-16s\n' "$C_GREEN" "$C_RESET" "imagemagick"
  else printf '  %s✗%s %-16s missing\n' "$C_RED" "$C_RESET" "imagemagick"; fi

  section "typst";      chk typst typst || true; chk tinymist tinymist "or let Mason / typst-preview install it" || true
  section "sql";        chk secret-tool secret-tool || true; chk sqlformat sqlformat || true
                        chk mariadb mariadb "only if you use MariaDB" || true
                        chk psql psql "only if you use PostgreSQL" || true
                        chk sqlite3 sqlite3 || true
  section "web";        chk php php || true; chk fuser fuser "package psmisc" || true; chk xdg-open xdg-open || true
  section "java";       chk javac javac "JDK 21+ for jdtls" || true
  section "c/c++";      chk clang clang || true; chk clang-format clang-format || true
  section "c#";         chk dotnet dotnet || true
  section "lua";        chk stylua stylua || true
  section "rust";       chk rustfmt rustfmt || true
  section "clipboard";  chk wl-copy wl-copy "Wayland" || true; chk xclip xclip "X11" || true
  section "font"
  if have fc-list && fc-list 2>/dev/null | grep -qi 'JetBrainsMono.*Nerd'; then
    printf '  %s✓%s %-16s\n' "$C_GREEN" "$C_RESET" "Nerd Font"
  else
    printf '  %s✗%s %-16s JetBrainsMono Nerd Font not found\n' "$C_RED" "$C_RESET" "Nerd Font"
  fi
  printf '\n'
  if [ "$bad" -eq 0 ]; then ok "Core dependencies look good. Run :checkhealth inside Neovim for plugin-level checks."
  else warn "$bad core dependency problem(s) found."; fi
  return 0
}

# INSTALL ORCHESTRATION
parse_modules() {
  local list="$1" m valid
  SELECTED=()
  IFS=',' read -r -a req <<<"$list"
  for m in "${req[@]}"; do
    m="${m// /}"
    [ -z "$m" ] && continue
    if [ "$m" = "all" ]; then SELECTED=("${MODULE_ORDER[@]}"); return 0; fi
    valid=0
    for v in "${MODULE_ORDER[@]}"; do [ "$v" = "$m" ] && valid=1; done
    [ "$valid" -eq 1 ] || die "Unknown module '$m'. Run --list-modules."
    SELECTED+=("$m")
  done
}

ask_modules() {
  local m
  SELECTED=()
  for m in "${MODULE_ORDER[@]}"; do
    if confirm "Install module '$m' - ${MOD_DESC[$m]}?" N; then SELECTED+=("$m"); fi
  done
}

resolve_family() {
  if [ -n "$FAMILY" ]; then return 0; fi
  FAMILY="$(detect_family)"
  if [ -n "$FAMILY" ]; then return 0; fi
  if [ "$HAVE_TTY" -eq 1 ] && [ "$ASSUME_YES" -eq 0 ]; then
    local ans
    prompt "Could not detect your distro. Type one of arch/ubuntu/debian/fedora/opensuse: " ans
    FAMILY="$(normalize_family "$ans")"
  fi
  [ -n "$FAMILY" ] || die "Unsupported or undetected distro. Use --distro arch|ubuntu|debian|fedora|opensuse."
}

experimental_notice() {
  case "$FAMILY" in
    fedora|opensuse)
      warn "$FAMILY support is EXPERIMENTAL: package names were not verified on a real system."
      warn "Packages missing from your repos will be skipped with a warning; run --check afterwards."
      if ! confirm "Continue?" Y; then die "Aborted."; fi ;;
  esac
}

summary_and_confirm() {
  section "Plan"
  printf '  distro      : %s (%s)%s\n' "$FAMILY" "${DISTRO_ID:-manual}" "$([ "$DRY_RUN" -eq 1 ] && echo ' [dry-run]')"
  printf '  core        : %s\n' "$([ "$SKIP_CORE" -eq 1 ] && echo skipped || echo yes)"
  printf '  modules     : %s\n' "${SELECTED[*]:-none}"
  if has_module sql; then printf '  sql engines : %s\n' "$SQL_ENGINES"; fi
  printf '  config      : %s\n' "$([ "$NO_CONFIG" -eq 1 ] && echo skipped || echo "$NVIM_CONFIG")"
  printf '  plugin sync : %s\n\n' "$([ "$NO_SYNC" -eq 1 ] && echo skipped || echo yes)"
  if ! confirm "Proceed?" Y; then die "Aborted."; fi
}

run_install() {
  local m
  resolve_family
  experimental_notice
  summary_and_confirm
  export PATH="$BIN_DIR:$PATH"

  PKG_SPECS=()
  if [ "$SKIP_CORE" -eq 0 ]; then
    # shellcheck disable=SC2207
    PKG_SPECS+=($(core_pkgs))
  fi
  if [ "${#SELECTED[@]}" -gt 0 ]; then
    for m in "${SELECTED[@]}"; do
      # shellcheck disable=SC2207
      PKG_SPECS+=($(module_pkgs "$m"))
    done
  fi
  if [ "${#PKG_SPECS[@]}" -gt 0 ]; then
    section "System packages"
    install_pkgs "${PKG_SPECS[@]}"
  fi

  if [ "$SKIP_CORE" -eq 0 ]; then section "Core tools"; post_core; fi
  if [ "$NO_CONFIG" -eq 0 ]; then section "Neovim config"; install_config; fi
  if [ "${#SELECTED[@]}" -gt 0 ]; then
    for m in "${SELECTED[@]}"; do
      section "Module: $m"
      case "$m" in
        python) post_python ;;
        typst)  post_typst ;;
        sql)    post_sql ;;
        csharp) post_csharp ;;
        lua)    post_lua ;;
        font)   post_font ;;
        cpp)    post_cpp ;;
        *)      ok "nothing else to do" ;;
      esac
    done
  fi
  section "Plugins"; sync_plugins
  final_notes
}

final_notes() {
  section "Done"
  case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) warn "$BIN_DIR is not in your PATH. Add: export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
  esac
  if [ "$DRY_RUN" -eq 0 ] && have nvim; then
    case "$(command -v nvim)" in
      "$BIN_DIR/nvim") ;;
      *) if [ -x "$BIN_DIR/nvim" ]; then warn "A different nvim ($(command -v nvim)) shadows $BIN_DIR/nvim; fix your PATH order."; fi ;;
    esac
  fi
  cat <<EOF
Next steps
  * Open nvim: Mason installs the language servers on first start (:Mason to watch it).
  * Run :checkhealth and ./install.sh --check to verify everything.
  * Set your terminal font to "JetBrainsMono Nerd Font Mono" (or any Nerd Font).
  * Inline images (Molten/image.nvim) need a kitty-graphics terminal: kitty, ghostty or wezterm.
  * Typst/Mermaid previews open a browser. Quarto is not installed by this script (quarto.org).
EOF
}

# INTERACTIVE MENU
menu_pick_modules() {
  local i=1 m input tok
  printf '\n'
  for m in "${MODULE_ORDER[@]}"; do
    printf '  %2d) %-10s %s\n' "$i" "$m" "${MOD_DESC[$m]}"; i=$((i+1))
  done
  prompt "Numbers separated by spaces, 'a' for all, Enter for none: " input
  SELECTED=()
  if [ "$input" = "a" ] || [ "$input" = "all" ]; then SELECTED=("${MODULE_ORDER[@]}"); return 0; fi
  for tok in $input; do
    case "$tok" in
      ''|*[!0-9]*) warn "Ignoring '$tok'" ;;
      *) if [ "$tok" -ge 1 ] && [ "$tok" -le "${#MODULE_ORDER[@]}" ]; then
           SELECTED+=("${MODULE_ORDER[$((tok-1))]}")
         else warn "Ignoring '$tok'"; fi ;;
    esac
  done
}

menu_sql_engines() {
  local ans
  if has_module sql; then
    prompt "SQL engines (mariadb postgres sqlite), Enter = all: " ans
    if [ -n "$ans" ]; then SQL_ENGINES="$(printf '%s' "$ans" | tr ' ' ',')"; fi
  fi
}

menu() {
  local choice ans
  if [ "$HAVE_TTY" -eq 0 ]; then
    usage; printf '\n'; die "No terminal available for the menu. Pass flags instead (see above)."
  fi
  FAMILY="${FAMILY:-$(detect_family)}"
  while true; do
    printf '\n%snvim setup installer v%s%s\n' "$C_BOLD" "$SCRIPT_VERSION" "$C_RESET"
    printf 'Distro: %s%s\n' "${FAMILY:-undetected}" "${DISTRO_ID:+ ($DISTRO_ID)}"
    cat <<'EOF'

  1) Full install      (core + every module)
  2) Custom install    (choose modules)
  3) Core only         (Neovim, tree-sitter, search tools, build tools)
  4) Check dependencies
  5) Install / update the Neovim config only
  6) Change distro
  7) Help (all flags)
  0) Quit

EOF
    prompt "Choose an option: " choice
    case "$choice" in
      1) SELECTED=("${MODULE_ORDER[@]}"); run_install; return 0 ;;
      2) menu_pick_modules; menu_sql_engines; run_install; return 0 ;;
      3) SELECTED=(); run_install; return 0 ;;
      4) doctor ;;
      5) SKIP_CORE=1; SELECTED=(); NO_CONFIG=0; run_install; return 0 ;;
      6) prompt "Distro (arch/ubuntu/debian/fedora/opensuse): " ans
         ans="$(normalize_family "$ans")"
         if [ -n "$ans" ]; then FAMILY="$ans"; else warn "Unknown distro"; fi ;;
      7) usage ;;
      0|q|Q) return 0 ;;
      *) warn "Invalid option" ;;
    esac
  done
}

# ARGUMENT PARSING
parse_args() {
  local a val
  while [ "$#" -gt 0 ]; do
    a="$1"
    case "$a" in
      --*=*) val="${a#*=}"; a="${a%%=*}"; set -- "$a" "$val" "${@:2}" ;;
    esac
    case "$1" in
      -h|--help)         ACTION="help" ;;
      -v|--version)      ACTION="version" ;;
      -l|--list-modules) ACTION="list" ;;
      -c|--check)        ACTION="check" ;;
      --config-only)     ACTION="config" ;;
      -d|--distro)       [ "$#" -ge 2 ] || die "--distro needs a value"
                         FAMILY="$(normalize_family "$2")"; [ -n "$FAMILY" ] || die "Unknown distro '$2'"
                         DISTRO_ID="$2"; shift ;;
      -m|--modules)      [ "$#" -ge 2 ] || die "--modules needs a value"; MODULES_ARG="$2"; shift ;;
      -a|--all)          ALL_MODULES=1 ;;
      --ask)             ASK_MODULES=1 ;;
      --sql-engines)     [ "$#" -ge 2 ] || die "--sql-engines needs a value"; SQL_ENGINES="$2"; shift ;;
      --python-extras)   PY_EXTRAS=1 ;;
      --skip-core)       SKIP_CORE=1 ;;
      --no-config)       NO_CONFIG=1 ;;
      --no-sync)         NO_SYNC=1 ;;
      --no-python-hook)  NO_PY_HOOK=1 ;;
      --repo)            [ "$#" -ge 2 ] || die "--repo needs a value"; REPO_URL="$2"; shift ;;
      -y|--yes)          ASSUME_YES=1 ;;
      -n|--dry-run)      DRY_RUN=1 ;;
      *) err "Unknown option: $1"; printf '\n'; usage >&2; exit 2 ;;
    esac
    shift
  done
}

validate_sql_engines() {
  local e
  for e in ${SQL_ENGINES//,/ }; do
    case "$e" in mariadb|postgres|sqlite) ;; *) die "Unknown SQL engine '$e' (use mariadb, postgres, sqlite)" ;; esac
  done
}

main() {
  if [ "$(id -u)" -eq 0 ] && [ -z "${SUDO_USER:-}" ] && [ "${NVIM_SETUP_ALLOW_ROOT:-0}" != "1" ]; then
    warn "Running as root: tools and the config will be installed for root, not for a regular user."
  fi

  if [ "$#" -eq 0 ]; then ACTION="menu"; else parse_args "$@"; fi
  init_tty
  validate_sql_engines

  if [ "$ASSUME_YES" -eq 0 ] && [ "$HAVE_TTY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ "$ACTION" != "help" ] && [ "$ACTION" != "version" ] && [ "$ACTION" != "list" ] && [ "$ACTION" != "check" ]; then
    warn "No terminal for prompts: assuming --yes."
    ASSUME_YES=1
  fi

  case "${ACTION:-install}" in
    help)    usage ;;
    version) echo "$SCRIPT_VERSION" ;;
    list)    list_modules ;;
    check)   doctor ;;
    menu)    menu ;;
    config)  resolve_family; SKIP_CORE=1; SELECTED=(); NO_CONFIG=0; export PATH="$BIN_DIR:$PATH"
             section "Neovim config"; install_config; sync_plugins ;;
    install)
      if [ "$ALL_MODULES" -eq 1 ]; then SELECTED=("${MODULE_ORDER[@]}")
      elif [ -n "$MODULES_ARG" ]; then parse_modules "$MODULES_ARG"
      elif [ "$ASK_MODULES" -eq 1 ] || { [ "$HAVE_TTY" -eq 1 ] && [ "$ASSUME_YES" -eq 0 ]; }; then ask_modules
      else SELECTED=(); fi
      if has_module sql && [ "$ASK_MODULES" -eq 1 ] && [ "$HAVE_TTY" -eq 1 ] && [ "$ASSUME_YES" -eq 0 ]; then
        menu_sql_engines
      fi
      run_install ;;
  esac
}

main "$@"
