#!/bin/bash

# Safe Testing Script for macOS Development Environment Setup
# This script creates an isolated test environment to validate the setup script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create isolated test environment
TEST_DIR="/tmp/zsh_setup_test_$(date +%s)"
mkdir -p "$TEST_DIR"

print_status "Creating isolated test environment at: $TEST_DIR"

# Copy current configs to test directory (simulating existing setup)
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$TEST_DIR/.zshrc"
    print_success "Copied existing .zshrc to test environment"
else
    print_warning "No existing .zshrc found"
fi

if [ -f "$HOME/.zprofile" ]; then
    cp "$HOME/.zprofile" "$TEST_DIR/.zprofile"
    print_success "Copied existing .zprofile to test environment"
else
    print_warning "No existing .zprofile found"
fi

# Create a modified version of the setup script that works in test environment
cat > "$TEST_DIR/test_setup.sh" << 'EOF'
#!/bin/bash

# Test version of setup script - operates on test directory only
# This version simulates the setup without touching your real config files

set -e

# Override HOME for testing
TEST_HOME="$1"
if [ -z "$TEST_HOME" ]; then
    echo "Error: TEST_HOME directory required"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Helper functions for merging zsh configurations (modified for testing)
add_to_zprofile() {
    local content="$1"
    local comment="$2"

    if [ -f "$TEST_HOME/.zprofile" ]; then
        if ! grep -Fq "$content" "$TEST_HOME/.zprofile"; then
            echo "" >> "$TEST_HOME/.zprofile"
            [ -n "$comment" ] && echo "$comment" >> "$TEST_HOME/.zprofile"
            echo "$content" >> "$TEST_HOME/.zprofile"
            print_success "Would add to .zprofile: $comment"
        else
            print_success "Already exists in .zprofile: $comment"
        fi
    else
        echo "$content" > "$TEST_HOME/.zprofile"
        print_success "Would create .zprofile with: $comment"
    fi
}

add_to_zshrc() {
    local content="$1"
    local comment="$2"
    local marker="$3"

    if [ -f "$TEST_HOME/.zshrc" ]; then
        if [ -n "$marker" ] && grep -q "$marker" "$TEST_HOME/.zshrc"; then
            print_success "Already exists in .zshrc: $comment"
            return
        elif [ -z "$marker" ] && grep -Fq "$content" "$TEST_HOME/.zshrc"; then
            print_success "Already exists in .zshrc: $comment"
            return
        fi

        echo "" >> "$TEST_HOME/.zshrc"
        [ -n "$comment" ] && echo "$comment" >> "$TEST_HOME/.zshrc"
        echo "$content" >> "$TEST_HOME/.zshrc"
        print_success "Would add to .zshrc: $comment"
    else
        echo "$content" > "$TEST_HOME/.zshrc"
        print_success "Would create .zshrc with: $comment"
    fi
}

update_oh_my_zsh_config() {
    if [ -f "$TEST_HOME/.zshrc" ]; then
        # Check if Oh My Zsh is already configured
        if grep -q "export ZSH=" "$TEST_HOME/.zshrc"; then
            print_status "Oh My Zsh already configured in .zshrc, would update plugins..."

            # Update plugins line if it exists
            if grep -q "plugins=" "$TEST_HOME/.zshrc"; then
                # Get current plugins
                current_plugins=$(grep "plugins=" "$TEST_HOME/.zshrc" | head -1 | sed 's/plugins=(//' | sed 's/)//')
                new_plugins="git zsh-autosuggestions zsh-syntax-highlighting docker npm yarn brew"

                # Merge plugins (keep existing, add new ones)
                merged_plugins=$(echo "$current_plugins $new_plugins" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/ $//')

                # Replace plugins line
                sed -i.bak "s/plugins=.*/plugins=($merged_plugins)/" "$TEST_HOME/.zshrc"
                print_success "Would update Oh My Zsh plugins to: $merged_plugins"
            else
                add_to_zshrc "plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker npm yarn brew)" "# Oh My Zsh plugins" "plugins="
            fi

            # Update theme if not already agnoster
            if ! grep -q 'ZSH_THEME="agnoster"' "$TEST_HOME/.zshrc"; then
                if grep -q "ZSH_THEME=" "$TEST_HOME/.zshrc"; then
                    current_theme=$(grep "ZSH_THEME=" "$TEST_HOME/.zshrc" | head -1 | cut -d'"' -f2)
                    print_warning "Would change theme from '$current_theme' to 'agnoster'"
                    sed -i.bak 's/ZSH_THEME=.*/ZSH_THEME="agnoster"/' "$TEST_HOME/.zshrc"
                else
                    add_to_zshrc 'ZSH_THEME="agnoster"' "# Oh My Zsh theme" "ZSH_THEME="
                fi
            else
                print_success "Theme already set to agnoster"
            fi
        else
            print_status "Would add Oh My Zsh configuration to existing .zshrc..."
            add_oh_my_zsh_config
        fi
    else
        print_status "Would create new .zshrc with Oh My Zsh configuration..."
        add_oh_my_zsh_config
    fi
}

add_oh_my_zsh_config() {
    cat >> "$TEST_HOME/.zshrc" << 'EOFCONFIG'

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="agnoster"

# Which plugins would you like to load?
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker npm yarn brew)

source $ZSH/oh-my-zsh.sh
EOFCONFIG
    print_success "Would add Oh My Zsh configuration"
}

print_status "Testing configuration merging logic..."

# Test the configuration additions
print_status "Testing .zprofile additions..."
add_to_zprofile 'eval "$(/opt/homebrew/bin/brew shellenv)"' "# Homebrew environment"
add_to_zprofile 'export PATH="$PATH:/Users/johnjenkins/Library/Application Support/JetBrains/Toolbox/scripts"' "# JetBrains Toolbox"

print_status "Testing Oh My Zsh configuration..."
update_oh_my_zsh_config

print_status "Testing other configuration additions..."
nvm_config='export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
add_to_zshrc "$nvm_config" "# NVM configuration" "NVM_DIR"

jenv_config='export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"'
add_to_zshrc "$jenv_config" "# jenv configuration" "jenv init"

add_to_zshrc 'export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"' "# VS Code command line tool" "Visual Studio Code"

print_success "Test completed! Check the files in $TEST_HOME to see what would be changed."
EOF

chmod +x "$TEST_DIR/test_setup.sh"

print_status "Running test simulation..."
cd "$TEST_DIR"
./test_setup.sh "$TEST_DIR"

print_status "Test Results:"
echo ""
print_status "=== ORIGINAL .zshrc (if existed) ==="
if [ -f "$TEST_DIR/.zshrc.bak" ]; then
    echo "Backup created at: $TEST_DIR/.zshrc.bak"
fi

print_status "=== WHAT WOULD BE IN YOUR NEW .zshrc ==="
if [ -f "$TEST_DIR/.zshrc" ]; then
    echo "--- First 50 lines ---"
    head -50 "$TEST_DIR/.zshrc"
    echo ""
    echo "--- Last 20 lines ---"
    tail -20 "$TEST_DIR/.zshrc"
    echo ""
    total_lines=$(wc -l < "$TEST_DIR/.zshrc")
    echo "Total lines: $total_lines"
else
    print_warning "No .zshrc was created"
fi

print_status "=== WHAT WOULD BE IN YOUR NEW .zprofile ==="
if [ -f "$TEST_DIR/.zprofile" ]; then
    cat "$TEST_DIR/.zprofile"
else
    print_warning "No .zprofile was created"
fi

echo ""
print_success "Test completed successfully!"
print_status "Test files are available at: $TEST_DIR"
print_status "You can inspect them with:"
echo "  ls -la $TEST_DIR"
echo "  cat $TEST_DIR/.zshrc"
echo "  cat $TEST_DIR/.zprofile"
echo ""
print_warning "To clean up test directory later:"
echo "  rm -rf $TEST_DIR"