# macOS Development Environment Setup

A comprehensive, automated setup script for configuring a complete macOS development environment. This repository provides a one-command solution to establish a professional development workspace with modern CLI tools, shell enhancements, Java environment management, and productivity configurations.

## Overview

This setup script creates a unified development environment that includes:

- **Modern Shell Environment**: Oh My Zsh with productivity plugins and enhanced CLI tools
- **Java Development**: Complete Java ecosystem with version management via jenv
- **Node.js Development**: NVM for Node.js version management
- **Enhanced CLI Tools**: Modern replacements for traditional Unix commands
- **Productivity Configurations**: Custom aliases, shell options, and workflow optimizations

## Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd local-setup

# Make the script executable (if needed)
chmod +x setup-macos.sh

# RECOMMENDED: Test first with dry-run mode
./setup-macos.sh --dry-run

# RECOMMENDED: Test with isolated environment
./test-setup.sh

# Run the setup
./setup-macos.sh

# Validate the installation
./validate-setup.sh

# Restart your terminal or reload configuration
source ~/.zshrc
```

## System Requirements

- macOS (Darwin-based system)
- Internet connection for downloading packages
- Administrator privileges for Homebrew installation
- Approximately 500MB of disk space for all components

## What Gets Installed

### Core Package Manager

- **Homebrew**: The missing package manager for macOS
  - Installed to `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel)
  - Automatically added to system PATH

### Shell Environment

- **Oh My Zsh**: Framework for managing zsh configuration
  - Theme: `agnoster` (powerline-style prompt)
  - Automatic installation without user interaction

### Oh My Zsh Plugins

- **git**: Git integration and aliases
- **zsh-autosuggestions**: Fish-like command suggestions
- **zsh-syntax-highlighting**: Real-time command syntax highlighting
- **docker**: Docker command completion
- **npm**: NPM command completion
- **yarn**: Yarn command completion
- **brew**: Homebrew command completion

### CLI Tools

| Tool | Purpose | Replaces |
|------|---------|----------|
| `eza` | Modern file listing | `ls` |
| `bat` | Syntax-highlighted file viewer | `cat` |
| `fd` | Fast file finder | `find` |
| `fzf` | Fuzzy finder for files/commands | grep/find |
| `ripgrep` | Ultra-fast text search | `grep` |

### Java Development Environment

- **OpenJDK 21**: Latest LTS Java version
- **jenv**: Java version management tool
  - Configured with OpenJDK 21 as global version
  - Enables switching between Java versions per project

### Node.js Development

- **NVM (Node Version Manager)**: Manage multiple Node.js versions
  - Latest version: v0.39.7
  - Configured for easy version switching

### GUI Applications

- **GitHub Copilot for Xcode**: AI-powered coding assistance for iOS development

## Configuration Details

### Shell Configuration Features

#### Enhanced History Management
```bash
HISTSIZE=50000              # Commands to keep in memory
SAVEHIST=50000              # Commands to save to file
HIST_IGNORE_DUPS=true       # Ignore duplicate commands
SHARE_HISTORY=true          # Share history across sessions
```

#### Intelligent Completion
- Case-insensitive tab completion
- Menu-driven selection for multiple matches
- Enhanced process completion for kill commands

#### Directory Navigation
- Auto-cd: Type directory name to navigate
- Pushd stack: Navigate directory history with `cd -`
- Duplicate directory prevention

#### Advanced Globbing
- Extended glob patterns (`**`, `^`, `~`)
- Include dotfiles in glob expansion

### Custom Aliases

#### File Operations
```bash
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first --git"
alias la="eza -a --icons --group-directories-first"
alias lt="eza --tree --level=2 --icons"
alias cat="bat"
alias find="fd"
alias grep="rg"
```

#### Git Workflow
```bash
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline --graph --decorate"
```

#### System Utilities
```bash
alias reload="source ~/.zshrc"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias h="history"
alias path='echo -e ${PATH//:/\\n}'
alias df="df -h"
alias du="du -h"
```

### FZF Integration

The setup configures FZF (fuzzy finder) with optimized defaults:

```bash
# Use fd for file searching (respects .gitignore)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
```

#### Key Bindings
- `Ctrl+T`: Fuzzy find files in current directory
- `Ctrl+R`: Fuzzy search command history
- `Alt+C`: Fuzzy find and cd into directory

### Java Environment Configuration

#### jenv Setup
```bash
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
```

#### Java Version Management
- Global version set to Java 21
- Per-project version configuration support
- Automatic JAVA_HOME management

### Development Tools Integration

#### VS Code Command Line
```bash
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
```

#### NVM Configuration
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

## Testing and Safety Features

This repository includes comprehensive testing and safety features to ensure reliable setup without disrupting your existing environment:

### 1. Dry-Run Mode
Test what the script would do without making any changes:
```bash
./setup-macos.sh --dry-run
# or
./setup-macos.sh -n
```

**Features:**
- Shows exactly what would be installed or modified
- Previews configuration changes before applying
- Safe to run multiple times
- No system modifications made

### 2. Isolated Test Environment
Validate the configuration merging logic in a safe sandbox:
```bash
./test-setup.sh
```

**What it does:**
- Creates temporary test environment in `/tmp`
- Copies your existing configurations for testing
- Simulates the setup process without touching real files
- Shows preview of merged configurations
- Displays before/after comparison of config files

### 3. Setup Validation
Verify your installation was successful:
```bash
./validate-setup.sh
```

**Validation checks:**
- Homebrew installation and tool availability
- Java and jenv configuration
- Oh My Zsh and plugin installation
- Shell configuration integrity
- Environment variable setup
- Path configurations

## Smart Configuration Merging

The setup script intelligently merges with existing configurations instead of overwriting them:

### Automatic Backups
- Creates timestamped backups before any changes: `.zshrc.backup.YYYYMMDD_HHMMSS`
- Preserves existing configurations for safe rollback
- Multiple backup versions maintained automatically

### Duplicate Detection
- Prevents adding identical configurations multiple times
- Checks for existing entries before appending
- Uses smart markers to detect previously added sections

### Intelligent Merging
- **Oh My Zsh plugins**: Merges new plugins with existing ones (no duplicates)
- **Aliases**: Only adds missing aliases, preserves custom ones
- **Environment variables**: Checks existence before adding
- **Themes**: Updates only if different theme is configured

## Safe Testing Workflow

Follow this recommended workflow for safe testing and deployment:

### Step 1: Initial Assessment
```bash
# Check what's currently installed
./validate-setup.sh

# See what would change with dry-run
./setup-macos.sh --dry-run
```

### Step 2: Isolated Testing
```bash
# Test configuration merging in safe environment
./test-setup.sh

# Review the test output and generated files
# Test directory location will be shown in output
```

### Step 3: Apply Changes
```bash
# Run the actual setup (creates automatic backups)
./setup-macos.sh
```

### Step 4: Validate Installation
```bash
# Verify everything was installed correctly
./validate-setup.sh

# Restart terminal to apply all changes
# Test key functionality
```

## File Structure

```
local-setup/
├── setup-macos.sh          # Main setup script with smart merging
├── test-setup.sh           # Isolated testing environment
├── validate-setup.sh       # Installation validation script
└── README.md               # This documentation

# Generated/Modified Files:
~/.zshrc                    # Main zsh configuration (smartly merged)
~/.zprofile                 # Environment setup and PATH (smartly merged)
~/.oh-my-zsh/               # Oh My Zsh installation
~/.jenv/                    # Java version management
~/.nvm/                     # Node Version Manager
~/.fzf.zsh                  # FZF key bindings

# Backup Files (automatically created):
~/.zshrc.backup.YYYYMMDD_HHMMSS     # Timestamped backups
~/.zprofile.backup.YYYYMMDD_HHMMSS  # Preserve original configs
```

### Backup Strategy

The script automatically creates timestamped backups before making any changes:
- `~/.zshrc` → `~/.zshrc.backup.YYYYMMDD_HHMMSS`
- `~/.zprofile` → `~/.zprofile.backup.YYYYMMDD_HHMMSS`

**Backup features:**
- Timestamped to allow multiple backup versions
- Created before any modifications are made
- Preserves exact original configurations
- Enables easy rollback if needed

**Restoring from backup:**
```bash
# List available backups
ls -la ~/.zshrc.backup.*

# Restore from a specific backup
cp ~/.zshrc.backup.20241226_143022 ~/.zshrc

# Restart terminal or reload
source ~/.zshrc
```

## Usage Examples

### Java Development
```bash
# Check available Java versions
jenv versions

# Set Java version for current project
jenv local 21

# Set global Java version
jenv global 21

# Verify Java version
java -version
```

### Node.js Development
```bash
# Install latest Node.js
nvm install node

# Install specific version
nvm install 18.17.0

# Use specific version
nvm use 18.17.0

# Set default version
nvm alias default 18.17.0
```

### Enhanced CLI Usage
```bash
# Modern file listing with git status
ll

# Tree view of directories
lt

# Search files with preview
fzf --preview 'bat --color=always {}'

# Search text in files
rg "function" --type js

# Find files by name
fd "*.tsx" src/
```

### Custom Functions

#### Firefox Developer Mode
```bash
firefox-dev
```
Opens Firefox with web security disabled and developer tools enabled for local development.

## Post-Installation Steps

### Essential Git Configuration
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

### Node.js Setup
```bash
# Install latest LTS Node.js
nvm install --lts
nvm use --lts

# Install global packages
npm install -g yarn typescript eslint prettier
```

### VS Code Extensions (Optional)
```bash
# Install useful extensions
code --install-extension ms-vscode.vscode-json
code --install-extension ms-python.python
code --install-extension ms-vscode.vscode-typescript-next
```

## Troubleshooting

### Common Issues and Solutions

#### Homebrew Path Issues
If `brew` command is not found after installation:
```bash
# Add Homebrew to PATH manually
eval "$(/opt/homebrew/bin/brew shellenv)"

# For Intel Macs:
eval "$(/usr/local/bin/brew shellenv)"
```

#### jenv Not Detecting Java
If jenv doesn't see installed Java versions:
```bash
# Manually add Java to jenv
jenv add /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home

# List available versions
jenv versions

# Set global version
jenv global 21
```

#### Oh My Zsh Plugin Issues
If autosuggestions or syntax highlighting don't work:
```bash
# Reinstall plugins
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Reload configuration
source ~/.zshrc
```

#### NVM Command Not Found
If `nvm` is not available after installation:
```bash
# Source NVM manually
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Or restart terminal
```

#### FZF Key Bindings Not Working
If Ctrl+T or Ctrl+R don't work:
```bash
# Reinstall FZF bindings
$(brew --prefix)/opt/fzf/install --all

# Source FZF configuration
source ~/.fzf.zsh
```

#### Permission Denied Errors
If the script fails with permission errors:
```bash
# Make script executable
chmod +x setup-macos.sh

# Ensure you have admin privileges for Homebrew installation
```

### Performance Issues

#### Slow Shell Startup
If terminal takes long to start:
```bash
# Profile startup time
time zsh -i -c exit

# Disable unused plugins in ~/.zshrc
# Remove or comment out plugins you don't use
```

#### FZF Performance
For large repositories, optimize FZF:
```bash
# Add to ~/.zshrc for better performance
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
```

### Verification Commands

#### Check Installation Status
```bash
# Verify Homebrew
brew --version

# Check installed packages
brew list

# Verify Java setup
java -version
jenv versions

# Check Node.js
nvm --version
node --version

# Verify CLI tools
eza --version
bat --version
fd --version
fzf --version
rg --version
```

### Testing and Safety Feature Troubleshooting

#### Dry-Run Mode Issues

**Dry-run shows different results than expected:**
```bash
# Ensure you're using the latest script
git pull origin main

# Check if your shell environment differs from script assumptions
echo $SHELL
echo $PATH

# Run with verbose output
bash -x ./setup-macos.sh --dry-run
```

**Dry-run mode not working:**
```bash
# Verify script has execute permissions
chmod +x setup-macos.sh

# Check script syntax
bash -n setup-macos.sh

# Run directly with bash
bash setup-macos.sh --dry-run
```

#### Test Environment Issues

**test-setup.sh fails to create test directory:**
```bash
# Check /tmp permissions
ls -la /tmp

# Verify you have write access
touch /tmp/test-write && rm /tmp/test-write

# Run with sudo if needed (not recommended)
# Better: fix /tmp permissions instead
```

**Test shows different results than expected:**
```bash
# Check if your current configs are different
cat ~/.zshrc | head -20
cat ~/.zprofile | head -10

# Verify test script is using correct files
ls -la test-setup.sh
```

**Test directory cleanup:**
```bash
# Find all test directories
find /tmp -name "zsh_setup_test_*" -type d 2>/dev/null

# Clean up old test directories
find /tmp -name "zsh_setup_test_*" -type d -mtime +1 -exec rm -rf {} \; 2>/dev/null
```

#### Validation Script Issues

**validate-setup.sh reports failures after successful setup:**
```bash
# Restart terminal first
# Some checks require fresh shell environment

# Check PATH manually
echo $PATH | tr ':' '\n' | grep -E "(homebrew|jenv|nvm)"

# Source configurations manually
source ~/.zshrc
source ~/.zprofile

# Re-run validation
./validate-setup.sh
```

**Java/jenv validation fails:**
```bash
# Check jenv installation
jenv versions

# Add Java manually if needed
jenv add /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home

# Set global version
jenv global 21

# Verify
java -version
```

**NVM validation fails:**
```bash
# Source NVM manually
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check NVM installation
nvm --version

# Reinstall if needed
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

#### Configuration Merging Issues

**Duplicated configurations after running setup multiple times:**
```bash
# Check for duplicate entries
grep -n "Homebrew environment" ~/.zprofile
grep -n "NVM configuration" ~/.zshrc

# Clean up manually or restore from backup
cp ~/.zshrc.backup.YYYYMMDD_HHMMSS ~/.zshrc

# Use dry-run to verify before re-running
./setup-macos.sh --dry-run
```

**Oh My Zsh plugin conflicts:**
```bash
# Check current plugins
grep "plugins=" ~/.zshrc

# Manually fix plugin list if needed
# Edit ~/.zshrc and ensure plugins line looks like:
# plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker npm yarn brew)

# Reload configuration
source ~/.zshrc
```

**Backup restoration issues:**
```bash
# List all backups with details
ls -la ~/.zshrc.backup.* ~/.zprofile.backup.*

# Compare backup with current
diff ~/.zshrc.backup.YYYYMMDD_HHMMSS ~/.zshrc

# Restore specific backup
cp ~/.zshrc.backup.YYYYMMDD_HHMMSS ~/.zshrc
```

#### Permission and Access Issues

**Script fails with permission denied:**
```bash
# Make all scripts executable
chmod +x setup-macos.sh test-setup.sh validate-setup.sh

# Check file ownership
ls -la *.sh

# Fix ownership if needed
sudo chown $USER:staff *.sh
```

**Homebrew installation fails:**
```bash
# Check admin privileges
groups $USER

# Install Homebrew manually
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH manually
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
```

#### Recovery Procedures

**Complete rollback to pre-setup state:**
```bash
# Restore from backups
cp ~/.zshrc.backup.YYYYMMDD_HHMMSS ~/.zshrc
cp ~/.zprofile.backup.YYYYMMDD_HHMMSS ~/.zprofile

# Remove Oh My Zsh (if needed)
rm -rf ~/.oh-my-zsh

# Remove jenv (if needed)
rm -rf ~/.jenv

# Remove NVM (if needed)
rm -rf ~/.nvm

# Restart terminal
```

**Partial setup recovery:**
```bash
# Use validation to identify what's working
./validate-setup.sh

# Re-run setup for missing components only
./setup-macos.sh --dry-run  # Preview changes first

# Or manually install missing tools
brew install <missing-tool>
```

## Advanced Configuration

### Customizing the Setup

#### Adding Custom Aliases
Edit `~/.zshrc` and add to the aliases section:
```bash
# Custom development aliases
alias myproject="cd ~/Projects/MyProject"
alias serve="python -m http.server 8000"
alias mkcd='mkdir -p "$1" && cd "$1"'
```

#### Adding Environment Variables
Add to `~/.zprofile`:
```bash
# Custom environment variables
export EDITOR="code"
export BROWSER="open"
export JAVA_OPTS="-Xmx2g"
```

#### Installing Additional Homebrew Packages
```bash
# Add to the CLI_TOOLS array in setup-macos.sh
CLI_TOOLS=(
    # ... existing tools ...
    "htop"           # System monitor
    "tree"           # Directory tree viewer
    "wget"           # File downloader
    "jq"             # JSON processor
)
```

### IDE Integration

#### IntelliJ IDEA Setup
```bash
# Add IntelliJ command line tool
export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"
```

#### Xcode Configuration
The setup includes GitHub Copilot for Xcode for AI-assisted development.

## Security Considerations

### Script Safety
- The script only installs packages from official repositories
- All downloads use HTTPS
- No sudo commands except for Homebrew installation
- Configuration files are backed up before modification

### Network Requirements
The script requires internet access to:
- Download Homebrew installer
- Install packages via Homebrew
- Clone Oh My Zsh and plugins from GitHub
- Download NVM installer

## Performance Optimization

### Shell Startup Time
The configuration is optimized for fast startup:
- Lazy loading of NVM
- Efficient plugin loading
- Minimal external command execution

### Memory Usage
- History size limited to 50,000 commands
- Completion cache for faster tab completion
- Optimized glob patterns

## Contributing

### Adding New Tools
1. Add the tool to the appropriate array in `setup-macos.sh`
2. Update the README documentation
3. Test on a clean macOS installation
4. Submit a pull request

### Reporting Issues
Include the following information:
- macOS version
- Terminal application
- Complete error output
- Steps to reproduce

## License

This project is provided as-is for educational and productivity purposes. Feel free to modify and distribute according to your needs.

## Changelog

### Version 2.0 (Current)
- **Major Safety and Testing Features**:
  - Dry-run mode for previewing changes without modifications
  - Isolated test environment for safe validation
  - Comprehensive validation script for installation verification
- **Smart Configuration Merging**:
  - Intelligent merging with existing configurations
  - Automatic timestamped backups before changes
  - Duplicate detection and prevention
  - Oh My Zsh plugin merging without overwrites
- **Enhanced User Experience**:
  - Step-by-step safe testing workflow
  - Comprehensive troubleshooting documentation
  - Recovery procedures for rollback scenarios
  - Detailed configuration preview and validation

### Version 1.0
- Initial release with comprehensive macOS development environment
- Oh My Zsh with modern plugins
- Java 21 with jenv management
- Enhanced CLI tools (eza, bat, fd, fzf, ripgrep)
- NVM for Node.js development
- Custom aliases and shell optimizations