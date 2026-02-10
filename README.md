# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Requirements

### macOS

```bash
# Install Homebrew if you don't have it:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install core dependencies
brew install neovim git gcc cmake node python shellcheck stylua ripgrep fd fzf lazygit

# Install theme switching support (automatic dark/light mode)
brew install cormacrelf/tap/dark-notify

# Install formatters and additional tools
brew install --cask shfmt
npm install -g prettier @vue/language-server
pip3 install flake8
```

### Linux (Debian/Ubuntu)

```bash
# Update package list
sudo apt update

# Install core dependencies
# Note: The neovim package in Debian/Ubuntu repositories may be outdated (v0.10.x)
# LazyVim requires Neovim >= 0.11.2, so we'll install it manually below
sudo apt install -y git build-essential cmake nodejs npm python3 python3-pip shellcheck ripgrep fd-find fzf

# Install latest Neovim (required: >= 0.11.2 for LazyVim)
# For ARM64 (Raspberry Pi, etc.):
cd /tmp
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz
tar xzf nvim-linux-arm64.tar.gz
sudo mv nvim-linux-arm64 /usr/local/
sudo ln -sf /usr/local/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim

# For x86_64:
# wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
# tar xzf nvim-linux64.tar.gz
# sudo mv nvim-linux64 /usr/local/
# sudo ln -sf /usr/local/nvim-linux64/bin/nvim /usr/local/bin/nvim

# Install Rust (for stylua and other tools)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# Install Go (for shfmt)
wget -c https://dl.google.com/go/go1.21.0.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
export PATH=$PATH:/usr/local/go/bin

# Install Rust and Go tools
cargo install stylua
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Install Node.js tools
sudo npm install -g prettier @vue/language-server tree-sitter-cli

# Install Python tools
pip3 install flake8

# Install lazygit (optional but recommended)
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
# For ARM64:
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"
# For x86_64:
# curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# Add Rust, Go, and other tools to PATH
echo 'export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:$HOME/.cargo/bin"' >> ~/.bashrc
echo 'export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:$HOME/.cargo/bin"' >> ~/.zshrc
source ~/.bashrc  # or source ~/.zshrc if using zsh

# Create treesitter parser directory
mkdir -p ~/.local/share/nvim/site/parser
```

### Linux (Arch)

```bash
# Update package list
sudo pacman -Syu

# Install core dependencies
sudo pacman -S --noconfirm neovim git gcc cmake nodejs npm python python-pip shellcheck stylua shfmt flake8 ripgrep fd fzf lazygit

# Install Node.js tools
npm install -g prettier @vue/language-server
```

### Windows

1.  **Install Chocolatey:** Open PowerShell as Administrator and run:
    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    ```
2.  **Install dependencies:** Open a new PowerShell as Administrator and run:
    ```powershell
    # Install core tools
    choco install neovim git mingw cmake nodejs python shellcheck stylua shfmt ripgrep fd fzf lazygit

    # Install Node.js tools
    npm install -g prettier @vue/language-server

    # Install Python tools
    pip install flake8
    ```

### Termux

```bash
# Update package list
pkg update

# Install core dependencies
pkg install -y neovim git build-essential cmake nodejs python python-pip shellcheck stylua shfmt flake8 ripgrep fzf

# Install Node.js tools
npm install -g prettier @vue/language-server

# Note: fd and lazygit may not be available in Termux repositories
# Install fd alternative if available
pkg install -y find
```

## Language Server Installation

After setting up the dependencies, you can install language servers for additional languages using Mason:

```vim
:Mason
```

Or install specific servers with:

```vim
:LspInstall <server_name>
```

Common language servers available:
- `html-lsp` - HTML intellisense
- `ruby-lsp` or `solargraph` - Ruby language support (see Ruby setup below)
- `rubocop` - Ruby linting and formatting
- `lua-language-server` - Lua support
- `bash-language-server` - Shell script support
- `typescript-language-server` - TypeScript/JavaScript (already configured)
- `volar` - Vue.js support (already configured)

### Ruby Development Setup

For Ruby development with Solargraph language server:

1. **Install Ruby development headers** (required for native extensions):

   **Linux (Debian/Ubuntu):**
   ```bash
   sudo apt-get install ruby-dev
   ```

   **Linux (Arch):**
   ```bash
   sudo pacman -S ruby
   ```

   **macOS:**
   ```bash
   # Usually included with Homebrew Ruby
   brew install ruby
   ```

2. **Install Solargraph gem**:
   ```bash
   gem install solargraph
   ```

3. **Verify installation**:
   ```bash
   solargraph --version
   # Should output version number (e.g., 0.58.2)
   ```

**Note:** This configuration automatically detects and uses Solargraph from your user gem directory, so it works across different Ruby versions without manual path configuration.

### Vue Development Setup

For Vue.js development with proper TypeScript support:

1. **Install Vue Language Server** (specific version required):
   ```vim
   :MasonInstall vue-language-server@1.8.27
   ```

2. **Configure tsconfig.json** in your Vue project:
   ```json
   {
     "compilerOptions": {
       "plugins": [{ "name": "@vue/typescript-plugin" }]
     }
   }
   ```
