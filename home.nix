{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "ilyalabacheuski";
  home.homeDirectory = "/Users/ilyalabacheuski";

  # Packages installed in user profile
  home.packages = with pkgs; [
    # Shell
    fish
    nushell      # Additional shell from brew list
    
    # Development tools
    rustc
    cargo
    rustup       # From brew - better Rust toolchain management
    go
    lua
    fnm          # Fast Node Manager

    
    # Rust coreutils replacements
    uutils-coreutils # Rust coreutils (prefixed: uutils-cp, uutils-ls, etc.)
    
    # CLI utilities
    ripgrep      # Better grep
    fd           # Better find
    bat          # Better cat
    eza          # Better ls
    fzf          # Fuzzy finder
    jq           # JSON processor
    yq           # YAML processor
    zoxide       # Better cd
    xh           # Better curl/httpie
    du-dust      # Better du (rust)
    dua          # Disk usage analyzer
    gdu          # From brew - another disk usage tool (faster for large dirs)
    bottom       # From brew - better htop/top replacement
    hyperfine    # Benchmarking tool
    just         # Command runner
    presenterm   # Markdown presentations in terminal
    zellij       # Terminal multiplexer

    tree-sitter  # From brew - parsing library for code
    usage        # From brew - tool to show usage examples
    
    # Development utilities
    gh           # GitHub CLI
    git-lfs      # Git Large File Storage
    delta        # Better git diff
    ripgrep-all  # ripgrep for all file types

    github-keygen # From brew - SSH key generation for GitHub
    
    # Rust development tools
    bacon        # Background rust code checker
    cargo-info   # Cargo crate info
    
    # Archive tools
    unzip
    p7zip
    
    # Network tools
    nmap
    speedtest-cli
    
    # Media
    ncspot       # Spotify TUI client
    
    # Browser
    ungoogled-chromium
    
    # System utilities
    gnupg        # From brew - GPG encryption
    pinentry     # From brew - GPG password entry
    
    # Just Neovim - NvChad will handle the rest
    neovim
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "open";  # Uses macOS default browser (Safari)
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Ilya Labacheuski";
    userEmail = "Ilya.labacheuski@gmail.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
      rerere.enabled = true;
      column.ui = "auto";
      branch.sort = "-committerdate";
      
      # Delta configuration for better diffs
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
      };
      
      # Git aliases
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        cm = "commit";
        ps = "push";
        pl = "pull";
        lg = "log --oneline --graph --decorate";
        last = "log -1 HEAD";
        unstage = "reset HEAD --";
      };
    };
  };

  # Fish shell configuration with session-based auto-updates
  programs.fish = {
    enable = true;
    
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -gx EDITOR nvim
      set -gx PATH /opt/homebrew/bin $PATH  # Add Homebrew to PATH
      
      # Auto-update Nix on session start (only once per day)
      set update_file ~/.cache/last_nix_update
      set current_date (date +%Y-%m-%d)
      
      if test -f $update_file
        set last_update (cat $update_file)
      else
        set last_update "never"
      end
      
      if test "$last_update" != "$current_date"
        echo "🔄 Running daily Nix update in background..."
        
        # Run update in background and show notification when done
        fish -c "
          cd ~/.config/nix
          echo '$(date): Session-triggered update started' >> ~/.cache/nix-session-update.log
          nix flake update >> ~/.cache/nix-session-update.log 2>&1
          darwin-rebuild switch --flake . >> ~/.cache/nix-session-update.log 2>&1
          nix-collect-garbage --delete-older-than 7d >> ~/.cache/nix-session-update.log 2>&1
          echo $current_date > $update_file
          echo '$(date): Session-triggered update completed' >> ~/.cache/nix-session-update.log
          osascript -e 'display notification \"Nix system updated successfully\" with title \"Session Update\"'
        " &
        
        echo "✅ Update started in background. Check ~/.cache/nix-session-update.log for progress."
      end
      
      # Set up colors
      set -U fish_color_normal normal
      set -U fish_color_command 005fd7
      set -U fish_color_quote 999900
      set -U fish_color_redirection 00afff
      set -U fish_color_end 009900
      set -U fish_color_error ff0000
    '';
    
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      
      # Modern CLI replacements
      ls = "eza --icons";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      tree = "eza --tree --icons";
      cat = "bat";
      grep = "rg";
      find = "fd";
      top = "bottom";  # Use bottom instead of htop
      
      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gco = "git checkout";
      gbr = "git branch";
      glog = "git log --oneline --graph";
      
      # System shortcuts
      vim = "nvim";
      vi = "nvim";
      df = "duf";
      du = "dust";
      
      # macOS specific
      flushdns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
      showfiles = "defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder";
      hidefiles = "defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder";
      
      # Nix shortcuts
      nix-switch = "darwin-rebuild switch --flake ~/.config/nix";
      nix-update = "cd ~/.config/nix && nix flake update && darwin-rebuild switch --flake .";
      nix-clean = "nix-collect-garbage -d && nix-store --optimise";
    };
    
    functions = {
      # Manual update function
      nix-update-now = {
        body = ''
          cd ~/.config/nix
          echo "🔄 Updating Nix configuration..."
          nix flake update
          darwin-rebuild switch --flake .
          nix-collect-garbage --delete-older-than 7d
          echo (date +%Y-%m-%d) > ~/.cache/last_nix_update
          echo "✅ Update complete!"
        '';
        description = "Update Nix configuration manually";
      };
      
      # Check update status
      nix-status = {
        body = ''
          if test -f ~/.cache/last_nix_update
            set last_update (cat ~/.cache/last_nix_update)
            echo "Last update: $last_update"
          else
            echo "Never updated"
          end
          
          echo ""
          echo "Recent scheduled update log:"
          if test -f ~/.cache/nix-update.log
            tail -5 ~/.cache/nix-update.log
          else
            echo "No scheduled updates yet"
          end
          
          echo ""
          echo "Recent session update log:"
          if test -f ~/.cache/nix-session-update.log
            tail -5 ~/.cache/nix-session-update.log
          else
            echo "No session updates yet"
          end
        '';
        description = "Check Nix update status and logs";
      };
      
      # Custom fish functions
      mkcd = {
        body = "mkdir -p $argv[1]; and cd $argv[1]";
        description = "Create a directory and cd into it";
      };
      
      backup = {
        body = "cp $argv[1] $argv[1].backup.(date +%Y%m%d_%H%M%S)";
        description = "Create a timestamped backup of a file";
      };
      
      extract = {
        body = ''
          switch $argv[1]
            case "*.tar.bz2"
              tar xjf $argv[1]
            case "*.tar.gz"
              tar xzf $argv[1]
            case "*.bz2"
              bunzip2 $argv[1]
            case "*.rar"
              unrar x $argv[1]
            case "*.gz"
              gunzip $argv[1]
            case "*.tar"
              tar xf $argv[1]
            case "*.tbz2"
              tar xjf $argv[1]
            case "*.tgz"
              tar xzf $argv[1]
            case "*.zip"
              unzip $argv[1]
            case "*.Z"
              uncompress $argv[1]
            case "*.7z"
              7z x $argv[1]
            case "*"
              echo "don't know how to extract '$argv[1]'"
          end
        '';
        description = "Extract various archive formats";
      };
      
      weather = {
        body = "curl -s 'https://wttr.in/$argv[1]?format=3'";
        description = "Get weather for a location";
      };
    };
    
    plugins = [
      {
        name = "tide";
        src = pkgs.fetchFromGitHub {
          owner = "IlanCosman";
          repo = "tide";
          rev = "v6.0.1";
          sha256 = "sha256-oLD7gYFCIeIzBeAW1j62z8FWz3gVowsxWYFB/9nuLkg=";
        };
      }
      {
        name = "fzf-fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "v10.3";
          sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
        };
      }
    ];
  };

  # Ghostty terminal configuration
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    
    settings = {
      theme = "Snazzy";
      
      # Additional sensible defaults
      font-family = "MesloLGS Nerd Font";
      font-size = 14;
      
      # Window settings
      window-decoration = true;
      window-title-font-family = "MesloLGS Nerd Font";
      
      # Terminal behavior
      cursor-style = "block";
      cursor-style-blink = false;
      
      # Performance
      macos-non-native-fullscreen = false;
    };
  };

  # Neovim - minimal config for NvChad
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Direnv for project environments
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    escapeTime = 0;
    historyLimit = 50000;
    aggressiveResize = true;
    
    extraConfig = ''
      # True color support
      set -ga terminal-overrides ",*256col*:Tc"
      set -g default-terminal "screen-256color"
      
      # Mouse support
      set -g mouse on
      
      # Vi mode
      setw -g mode-keys vi
      
      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %
      
      # Switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
      
      # Reload config file
      bind r source-file ~/.tmux.conf \; display "Config reloaded!"
      
      # Status bar
      set -g status-position bottom
      set -g status-bg colour234
      set -g status-fg colour137
    '';
  };

  # SSH configuration
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    
    matchBlocks = {
      "*" = {
        useKeychain = true;
        addKeysToAgent = "yes";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  # This value determines the Home Manager release that your configuration is compatible with
  home.stateVersion = "25.05";
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}