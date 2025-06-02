{ config, pkgs, self, ... }:

{
  # System-wide packages available to all users
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    
    # Auto-update script
    (writeShellScriptBin "nix-daily-update" ''
      #!/bin/bash
      set -e
      
      # Log with timestamp
      echo "$(date): Starting Nix daily update" >> ~/.cache/nix-update.log
      
      cd ~/.config/nix
      
      # Update flake inputs
      nix flake update 2>&1 | tee -a ~/.cache/nix-update.log
      
      # Rebuild system
      darwin-rebuild switch --flake . 2>&1 | tee -a ~/.cache/nix-update.log
      
      # Clean up old generations (keep last 7 days)
      nix-collect-garbage --delete-older-than 7d 2>&1 | tee -a ~/.cache/nix-update.log
      
      # Optimize store
      nix store optimise 2>&1 | tee -a ~/.cache/nix-update.log
      
      echo "$(date): Nix daily update completed" >> ~/.cache/nix-update.log
      
      # Send notification
      osascript -e 'display notification "Nix system updated successfully" with title "System Update"'
    '')
  ];

  # Set hostname
  networking.hostName = "mac-ilya";

  # Homebrew configuration
  homebrew = {
    enable = true;
    
    # Homebrew formulas (CLI tools)
    brews = [
      "mas"  # Mac App Store CLI
      "ffmpeg"
    ];
    
    # Homebrew casks (GUI applications)
    casks = [
      # Development
      "visual-studio-code"
      "zed"           # Modern code editor
      
      # Utilities
      "the-unarchiver"
      "raycast"       # Spotlight replacement
      "ghostty"       # Terminal emulator
      "obsidian"      # Note-taking app
      "gpg-suite"     # GPG tools for macOS
      "podman-desktop" # Container management
      
      # Media
      "spotify"
      "vlc"
    ];
    
    # Mac App Store apps
    masApps = {
      "Xcode" = 497799835;
      "TestFlight" = 899247664;
    };
    
    # Cleanup options
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  # System fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    nerd-fonts.meslo-lg
  ];

  # macOS system settings
  system.defaults = {
    # Dock settings
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.4;
      launchanim = false;
      minimize-to-application = true;
      mru-spaces = false;
      orientation = "bottom";
      show-recents = false;
      tilesize = 48;
    };

    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv";
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
    };

    # Login window settings
    loginwindow = {
      GuestEnabled = false;
      LoginwindowText = "Welcome to my Mac";
    };

    # Trackpad settings
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    # Screen capture settings
    screencapture = {
      location = "~/Desktop/Screenshots";
      type = "png";
    };

    # Screensaver settings
    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 10;
    };
  };

  # Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Auto-update LaunchAgent - runs daily at 8 AM
  launchd.user.agents.nix-daily-update = {
    serviceConfig = {
      ProgramArguments = [ 
        "${pkgs.bash}/bin/bash" 
        "-c" 
        "export PATH=/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH && nix-daily-update"
      ];
      StartCalendarInterval = [
        {
          Hour = 8;    # 8 AM
          Minute = 0;
        }
      ];
      StandardOutPath = "/Users/ilyalabacheuski/.cache/nix-update.log";
      StandardErrorPath = "/Users/ilyalabacheuski/.cache/nix-update-error.log";
      RunAtLoad = false;  # Set to true if you want it to run at login too
    };
  };

  # System services
  services.nix-daemon.enable = true;

  # Nix configuration
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = [ "@admin" ];
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };  # Sunday 2 AM
      options = "--delete-older-than 30d";
    };
  };

  # Programs enabled system-wide
  programs = {
    # Enable Fish shell system-wide
    fish.enable = true;
    
    # Enable Zsh (for compatibility)
    zsh.enable = true;
  };

  # Security settings
  security.pam.enableSudoTouchId = true;

  # Set Git commit hash for darwin-version
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility
  system.stateVersion = 6;

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";  # Change to "x86_64-darwin" for Intel Macs
}