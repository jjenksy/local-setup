#!/bin/bash

# Validation Script for macOS Development Environment Setup
# This script validates that the setup was applied correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

PASSED=0
FAILED=0
WARNINGS=0

check_pass() {
    print_success "$1"
    ((PASSED++))
}

check_fail() {
    print_error "$1"
    ((FAILED++))
}

check_warn() {
    print_warning "$1"
    ((WARNINGS++))
}

echo "🔍 Validating macOS Development Environment Setup"
echo ""

# Check Homebrew
print_status "Checking Homebrew installation..."
if command -v brew &> /dev/null; then
    check_pass "Homebrew is installed"
    brew_version=$(brew --version | head -1)
    echo "    Version: $brew_version"
else
    check_fail "Homebrew is not installed"
fi

# Check CLI tools
print_status "Checking CLI tools..."
CLI_TOOLS=("jenv" "eza" "bat" "fd" "fzf" "rg")
for tool in "${CLI_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        check_pass "$tool is installed"
    else
        check_fail "$tool is not installed"
    fi
done

# Check Java installation
print_status "Checking Java installation..."
if command -v java &> /dev/null; then
    java_version=$(java -version 2>&1 | head -1)
    check_pass "Java is installed: $java_version"

    # Check jenv versions
    if command -v jenv &> /dev/null; then
        jenv_versions=$(jenv versions 2>/dev/null | wc -l)
        if [ "$jenv_versions" -gt 1 ]; then
            check_pass "jenv has Java versions configured"
            echo "    Available versions:"
            jenv versions | sed 's/^/    /'
        else
            check_warn "jenv has no Java versions configured"
        fi
    fi
else
    check_fail "Java is not installed"
fi

# Check Oh My Zsh
print_status "Checking Oh My Zsh installation..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    check_pass "Oh My Zsh is installed"

    # Check plugins
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        check_pass "zsh-autosuggestions plugin is installed"
    else
        check_fail "zsh-autosuggestions plugin is missing"
    fi

    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        check_pass "zsh-syntax-highlighting plugin is installed"
    else
        check_fail "zsh-syntax-highlighting plugin is missing"
    fi
else
    check_fail "Oh My Zsh is not installed"
fi

# Check zsh configuration
print_status "Checking zsh configuration..."
if [ -f "$HOME/.zshrc" ]; then
    check_pass ".zshrc exists"

    # Check for key configurations
    if grep -q "export ZSH=" "$HOME/.zshrc"; then
        check_pass "Oh My Zsh configuration found in .zshrc"
    else
        check_warn "Oh My Zsh configuration not found in .zshrc"
    fi

    if grep -q 'ZSH_THEME="agnoster"' "$HOME/.zshrc"; then
        check_pass "agnoster theme is configured"
    else
        check_warn "agnoster theme is not configured"
    fi

    if grep -q "jenv init" "$HOME/.zshrc"; then
        check_pass "jenv configuration found in .zshrc"
    else
        check_fail "jenv configuration not found in .zshrc"
    fi

    if grep -q "NVM_DIR" "$HOME/.zshrc"; then
        check_pass "NVM configuration found in .zshrc"
    else
        check_warn "NVM configuration not found in .zshrc"
    fi

    # Check aliases
    if grep -q 'alias ls="eza' "$HOME/.zshrc"; then
        check_pass "Enhanced CLI aliases are configured"
    else
        check_warn "Enhanced CLI aliases are not configured"
    fi

else
    check_fail ".zshrc does not exist"
fi

# Check .zprofile
print_status "Checking .zprofile configuration..."
if [ -f "$HOME/.zprofile" ]; then
    check_pass ".zprofile exists"

    if grep -q "brew shellenv" "$HOME/.zprofile"; then
        check_pass "Homebrew environment configuration found"
    else
        check_warn "Homebrew environment configuration not found"
    fi
else
    check_warn ".zprofile does not exist"
fi

# Check NVM
print_status "Checking NVM installation..."
if [ -d "$HOME/.nvm" ]; then
    check_pass "NVM directory exists"
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        check_pass "NVM script is available"
    else
        check_fail "NVM script is missing"
    fi
else
    check_warn "NVM is not installed"
fi

# Check FZF
print_status "Checking FZF integration..."
if [ -f "$HOME/.fzf.zsh" ]; then
    check_pass "FZF zsh integration file exists"
else
    check_warn "FZF zsh integration file is missing"
fi

# Check environment variables in current shell
print_status "Checking current shell environment..."
if [[ ":$PATH:" == *":.jenv/bin:"* ]]; then
    check_pass "jenv is in PATH"
else
    check_warn "jenv is not in current PATH (may need shell restart)"
fi

if [[ ":$PATH:" == *":brew"* ]]; then
    check_pass "Homebrew is in PATH"
else
    check_warn "Homebrew is not in current PATH"
fi

# Summary
echo ""
echo "📊 Validation Summary"
echo "=================="
echo "✅ Passed: $PASSED"
echo "⚠️  Warnings: $WARNINGS"
echo "❌ Failed: $FAILED"

if [ "$FAILED" -eq 0 ]; then
    if [ "$WARNINGS" -eq 0 ]; then
        echo ""
        print_success "🎉 Perfect! Your development environment is fully configured."
    else
        echo ""
        print_warning "✅ Setup is mostly complete, but there are some warnings to review."
        echo "Most warnings can be resolved by restarting your terminal or running 'source ~/.zshrc'"
    fi
else
    echo ""
    print_error "❌ There are some issues with your setup that need attention."
    echo "Please review the failed checks above and re-run the setup script if needed."
fi

echo ""
echo "💡 Next steps:"
echo "• Restart your terminal or run 'source ~/.zshrc' to apply all changes"
echo "• Install Visual Studio Code if you haven't already"
echo "• Configure Git with your name and email: git config --global user.name 'Your Name'"
echo "• Install Node.js versions with NVM: nvm install node"