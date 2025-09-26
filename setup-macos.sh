#!/bin/bash

# macOS Development Environment Setup Script
# This script replicates the exact setup from the source machine

set -e

# Check for dry-run mode
DRY_RUN=false
if [[ "$1" == "--dry-run" || "$1" == "-n" ]]; then
    DRY_RUN=true
    echo "🔍 DRY RUN MODE: No changes will be made to your system"
    echo ""
fi

echo "🚀 Starting macOS Development Environment Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would: $1"
    else
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

print_success() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${GREEN}[DRY-RUN]${NC} Would succeed: $1"
    else
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    fi
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only!"
    exit 1
fi

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for the current session
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    print_success "Homebrew is already installed"
fi

# Update Homebrew
print_status "Updating Homebrew..."
brew update

# Install essential CLI tools
print_status "Installing essential CLI tools..."
CLI_TOOLS=(
    "jenv"           # Java version management
    "openjdk@21"     # Java 21
    "eza"            # Better ls
    "bat"            # Better cat
    "fd"             # Better find
    "fzf"            # Fuzzy finder
    "ripgrep"        # Better grep
)

for tool in "${CLI_TOOLS[@]}"; do
    if brew list "$tool" &>/dev/null; then
        print_success "$tool is already installed"
    else
        print_status "Installing $tool..."
        brew install "$tool"
    fi
done

# Install GUI applications (casks)
print_status "Installing GUI applications..."
CASK_APPS=(
    "github-copilot-for-xcode"
)

for app in "${CASK_APPS[@]}"; do
    if brew list --cask "$app" &>/dev/null; then
        print_success "$app is already installed"
    else
        print_status "Installing $app..."
        brew install --cask "$app"
    fi
done

# Setup Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_status "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    print_success "Oh My Zsh is already installed"
fi

# Install Oh My Zsh plugins
print_status "Installing Oh My Zsh plugins..."

# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    print_status "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    print_success "zsh-autosuggestions is already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    print_status "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    print_success "zsh-syntax-highlighting is already installed"
fi

# Install FZF key bindings and fuzzy completion
print_status "Installing FZF key bindings..."
$(brew --prefix)/opt/fzf/install --all

# Install NVM if not already installed
if [ ! -d "$HOME/.nvm" ]; then
    print_status "Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
    print_success "NVM is already installed"
fi

# Setup jenv
print_status "Setting up jenv..."
if [ -d "$HOME/.jenv" ]; then
    print_success "jenv is already configured"
else
    # Initialize jenv
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi

# Add Java 21 to jenv if not already added
if ! jenv versions | grep -q "21"; then
    print_status "Adding Java 21 to jenv..."
    jenv add /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
fi

# Set Java 21 as global version
print_status "Setting Java 21 as global version..."
jenv global 21 2>/dev/null || jenv global system

# Helper functions for merging zsh configurations
add_to_zprofile() {
    local content="$1"
    local comment="$2"

    if [ -f "$HOME/.zprofile" ]; then
        if ! grep -Fq "$content" "$HOME/.zprofile"; then
            if [[ "$DRY_RUN" == "false" ]]; then
                echo "" >> "$HOME/.zprofile"
                [ -n "$comment" ] && echo "$comment" >> "$HOME/.zprofile"
                echo "$content" >> "$HOME/.zprofile"
            fi
            print_success "Added to .zprofile: $comment"
        else
            print_success "Already exists in .zprofile: $comment"
        fi
    else
        if [[ "$DRY_RUN" == "false" ]]; then
            echo "$content" > "$HOME/.zprofile"
        fi
        print_success "Created .zprofile with: $comment"
    fi
}

add_to_zshrc() {
    local content="$1"
    local comment="$2"
    local marker="$3"

    if [ -f "$HOME/.zshrc" ]; then
        if [ -n "$marker" ] && grep -q "$marker" "$HOME/.zshrc"; then
            print_success "Already exists in .zshrc: $comment"
            return
        elif [ -z "$marker" ] && grep -Fq "$content" "$HOME/.zshrc"; then
            print_success "Already exists in .zshrc: $comment"
            return
        fi

        if [[ "$DRY_RUN" == "false" ]]; then
            echo "" >> "$HOME/.zshrc"
            [ -n "$comment" ] && echo "$comment" >> "$HOME/.zshrc"
            echo "$content" >> "$HOME/.zshrc"
        fi
        print_success "Added to .zshrc: $comment"
    else
        if [[ "$DRY_RUN" == "false" ]]; then
            echo "$content" > "$HOME/.zshrc"
        fi
        print_success "Created .zshrc with: $comment"
    fi
}

update_oh_my_zsh_config() {
    if [ -f "$HOME/.zshrc" ]; then
        # Check if Oh My Zsh is already configured
        if grep -q "export ZSH=" "$HOME/.zshrc"; then
            print_status "Oh My Zsh already configured in .zshrc, updating plugins..."

            # Update plugins line if it exists
            if grep -q "plugins=" "$HOME/.zshrc"; then
                # Get current plugins
                current_plugins=$(grep "plugins=" "$HOME/.zshrc" | head -1 | sed 's/plugins=(//' | sed 's/)//')
                new_plugins="git zsh-autosuggestions zsh-syntax-highlighting docker npm yarn brew"

                # Merge plugins (keep existing, add new ones)
                merged_plugins=$(echo "$current_plugins $new_plugins" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/ $//')

                # Replace plugins line
                if [[ "$DRY_RUN" == "false" ]]; then
                    sed -i.bak "s/plugins=.*/plugins=($merged_plugins)/" "$HOME/.zshrc"
                fi
                print_success "Updated Oh My Zsh plugins"
            else
                add_to_zshrc "plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker npm yarn brew)" "# Oh My Zsh plugins" "plugins="
            fi

            # Update theme if not already agnoster
            if ! grep -q 'ZSH_THEME="agnoster"' "$HOME/.zshrc"; then
                if grep -q "ZSH_THEME=" "$HOME/.zshrc"; then
                    if [[ "$DRY_RUN" == "false" ]]; then
                        sed -i.bak 's/ZSH_THEME=.*/ZSH_THEME="agnoster"/' "$HOME/.zshrc"
                    fi
                    print_success "Updated Oh My Zsh theme to agnoster"
                else
                    add_to_zshrc 'ZSH_THEME="agnoster"' "# Oh My Zsh theme" "ZSH_THEME="
                fi
            fi
        else
            print_status "Adding Oh My Zsh configuration to existing .zshrc..."
            add_oh_my_zsh_config
        fi
    else
        print_status "Creating new .zshrc with Oh My Zsh configuration..."
        add_oh_my_zsh_config
    fi
}

add_oh_my_zsh_config() {
    if [[ "$DRY_RUN" == "false" ]]; then
        cat >> "$HOME/.zshrc" << 'EOF'

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker npm yarn brew)

source $ZSH/oh-my-zsh.sh
EOF
    fi
    print_success "Added Oh My Zsh configuration"
}

# Backup existing zsh config files
print_status "Backing up existing zsh configuration files..."
for file in .zshrc .zprofile; do
    if [ -f "$HOME/$file" ]; then
        if [[ "$DRY_RUN" == "false" ]]; then
            cp "$HOME/$file" "$HOME/${file}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        print_success "Backed up $file"
    fi
done

# Setup .zprofile with Homebrew and other PATH additions
print_status "Setting up .zprofile..."
add_to_zprofile 'eval "$(/opt/homebrew/bin/brew shellenv)"' "# Homebrew environment"
add_to_zprofile 'export PATH="$PATH:/Users/johnjenkins/Library/Application Support/JetBrains/Toolbox/scripts"' "# JetBrains Toolbox"

# Setup Oh My Zsh configuration
print_status "Setting up Oh My Zsh configuration..."
update_oh_my_zsh_config

# Add NVM configuration
print_status "Adding NVM configuration..."
add_to_zshrc 'export NVM_DIR="$HOME/.nvm"' "# NVM configuration" "NVM_DIR"
add_to_zshrc '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' "" ""
add_to_zshrc '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' "" ""

# Add jenv configuration
print_status "Adding jenv configuration..."
add_to_zshrc 'export PATH="$HOME/.jenv/bin:$PATH"' "# jenv configuration" "jenv init"
add_to_zshrc 'eval "$(jenv init -)"' "" ""

# Add VS Code command line tool
print_status "Adding VS Code command line configuration..."
add_to_zshrc 'export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"' "# VS Code command line tool" "Visual Studio Code"

# Add FZF configuration
print_status "Adding FZF configuration..."
add_to_zshrc 'export FZF_DEFAULT_COMMAND='\''fd --type f --hidden --follow --exclude .git'\''' "# FZF configuration" "FZF_DEFAULT_COMMAND"
add_to_zshrc 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' "" ""
add_to_zshrc 'export FZF_ALT_C_COMMAND='\''fd --type d --hidden --follow --exclude .git'\''' "" ""

# Add better defaults aliases
print_status "Adding enhanced CLI aliases..."
add_to_zshrc '' "# Better defaults aliases" "Better defaults aliases"
add_to_zshrc 'alias ls="eza --icons --group-directories-first"' "" ""
add_to_zshrc 'alias ll="eza -la --icons --group-directories-first --git"' "" ""
add_to_zshrc 'alias la="eza -a --icons --group-directories-first"' "" ""
add_to_zshrc 'alias lt="eza --tree --level=2 --icons"' "" ""
add_to_zshrc 'alias cat="bat"' "" ""
add_to_zshrc 'alias find="fd"' "" ""
add_to_zshrc 'alias grep="rg"' "" ""
add_to_zshrc '' "" ""
add_to_zshrc '# Git aliases' "" ""
add_to_zshrc 'alias gs="git status"' "" ""
add_to_zshrc 'alias ga="git add"' "" ""
add_to_zshrc 'alias gc="git commit"' "" ""
add_to_zshrc 'alias gp="git push"' "" ""
add_to_zshrc 'alias gl="git pull"' "" ""
add_to_zshrc 'alias gd="git diff"' "" ""
add_to_zshrc 'alias gco="git checkout"' "" ""
add_to_zshrc 'alias gb="git branch"' "" ""
add_to_zshrc 'alias glog="git log --oneline --graph --decorate"' "" ""
add_to_zshrc '' "" ""
add_to_zshrc '# Utility aliases' "" ""
add_to_zshrc 'alias reload="source ~/.zshrc"' "" ""
add_to_zshrc 'alias ..="cd .."' "" ""
add_to_zshrc 'alias ...="cd ../.."' "" ""
add_to_zshrc 'alias ....="cd ../../.."' "" ""
add_to_zshrc 'alias h="history"' "" ""
add_to_zshrc 'alias path='\''echo -e ${PATH//:/\\n}'\''' "" ""
add_to_zshrc 'alias df="df -h"' "" ""
add_to_zshrc 'alias du="du -h"' "" ""

# Add enhanced autocompletion
print_status "Adding enhanced autocompletion..."
add_to_zshrc '' "# Enhanced autocompletion" "autoload -U compinit"
add_to_zshrc 'autoload -U compinit && compinit' "" ""
add_to_zshrc 'zstyle '\'':completion:*'\'' matcher-list '\''m:{a-z}={A-Za-z}'\''' "" ""
add_to_zshrc 'zstyle '\'':completion:*'\'' list-colors '\'''\''' "" ""
add_to_zshrc 'zstyle '\'':completion:*:*:*:*:*'\'' menu select' "" ""
add_to_zshrc 'zstyle '\'':completion:*:*:kill:*:processes'\'' list-colors '\''=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'\''' "" ""

# Add better history settings
print_status "Adding enhanced history configuration..."
add_to_zshrc '' "# Better history" "HISTSIZE=50000"
add_to_zshrc 'HISTSIZE=50000' "" ""
add_to_zshrc 'SAVEHIST=50000' "" ""
add_to_zshrc 'HISTFILE=~/.zsh_history' "" ""
add_to_zshrc 'setopt HIST_IGNORE_DUPS' "" ""
add_to_zshrc 'setopt HIST_IGNORE_ALL_DUPS' "" ""
add_to_zshrc 'setopt HIST_REDUCE_BLANKS' "" ""
add_to_zshrc 'setopt HIST_IGNORE_SPACE' "" ""
add_to_zshrc 'setopt HIST_NO_STORE' "" ""
add_to_zshrc 'setopt HIST_VERIFY' "" ""
add_to_zshrc 'setopt APPEND_HISTORY' "" ""
add_to_zshrc 'setopt EXTENDED_HISTORY' "" ""
add_to_zshrc 'setopt HIST_EXPIRE_DUPS_FIRST' "" ""
add_to_zshrc 'setopt HIST_FIND_NO_DUPS' "" ""
add_to_zshrc 'setopt HIST_SAVE_NO_DUPS' "" ""
add_to_zshrc 'setopt SHARE_HISTORY' "" ""

# Add better globbing and navigation
print_status "Adding enhanced shell options..."
add_to_zshrc '' "# Enhanced shell options" "setopt EXTENDED_GLOB"
add_to_zshrc '# Better globbing' "" ""
add_to_zshrc 'setopt EXTENDED_GLOB' "" ""
add_to_zshrc 'setopt GLOB_DOTS' "" ""
add_to_zshrc '' "" ""
add_to_zshrc '# Directory navigation' "" ""
add_to_zshrc 'setopt AUTO_CD' "" ""
add_to_zshrc 'setopt AUTO_PUSHD' "" ""
add_to_zshrc 'setopt PUSHD_IGNORE_DUPS' "" ""
add_to_zshrc 'setopt PUSHD_SILENT' "" ""
add_to_zshrc '' "" ""
add_to_zshrc '# Correction' "" ""
add_to_zshrc 'setopt CORRECT' "" ""
add_to_zshrc 'setopt CORRECT_ALL' "" ""

# Add FZF source if it exists
add_to_zshrc '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' "# FZF key bindings and fuzzy completion" "~/.fzf.zsh"

# Make the script executable
chmod +x "$0"

print_success "Setup complete!"
print_warning "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
print_status "Additional steps you may want to do manually:"
echo "  • Install Visual Studio Code and ensure the command line tool is available"
echo "  • Install Firefox if you want to use the firefox-dev function"
echo "  • Configure your Git user name and email"
echo "  • Install any additional Node.js versions with nvm"
echo ""
print_success "Your development environment is ready!"