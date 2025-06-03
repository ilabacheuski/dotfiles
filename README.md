# Nix macOS Configuration

Personal macOS configuration using Nix Darwin and Home Manager with automated updates and modern development tools.

## 🚀 Quick Start

### 1. Install Nix
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Clone Configuration
```bash
git clone <your-repo-url> ~/.config/nix
cd ~/.config/nix
```

### 3. Update Personal Settings
Edit `home.nix` and update:
- `home.username` - your macOS username
- `home.homeDirectory` - your home directory path
- Git user name and email in `programs.git`

Edit `darwin.nix` and update:
- `networking.hostName` - your preferred hostname

### 4. Build and Apply
```bash
# First time setup
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake "./flake.nix" --show-trace

# Subsequent updates
darwin-rebuild switch --flake ~/.config/nix
```

### 5. Set Fish as Default Shell
```bash
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)
```

## 🔄 Daily Usage

After setup, the system will automatically:
- Update daily at 8 AM (scheduled)
- Update once per session when you open a new terminal
- Send macOS notifications when updates complete

Manual update commands:
```bash
nix-update-now    # Update immediately
nix-status        # Check update status
```
