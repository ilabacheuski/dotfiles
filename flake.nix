{
  description = "MacOs standard machine Ilya";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
  {
    darwinConfigurations."mac-ilya" = nix-darwin.lib.darwinSystem {  # Change "Yourhost" to your hostname
      modules = [
        # Import the darwin configuration
        ./darwin.nix
        
        # Import Home Manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ilabacheuski = import ./home.nix;  # Change to your username
        }
      ];
    };

    # Expose the package set for convenience
    darwinPackages = self.darwinConfigurations."mac-ilya".pkgs;
  };
  # let
  #   configuration = { pkgs, ... }: {
  #     # List packages installed in system profile. To search by name, run:
  #     # $ nix-env -qaP | grep wget
  #     environment.systemPackages = with pkgs; [
  #       git
  #       neovim
  #       ripgrep
  #     ];

  #     environment.variables = {
  #       EDITOR = "nvim";
  #     };

  #     fonts.packages = [
  #         (pkgs.nerdfonts.override { fonts = ["MesloLG"]; })
  #       ];

  #     # Necessary for using flakes on this system.
  #     nix.settings.experimental-features = "nix-command flakes";

  #     # Enable alternative shell support in nix-darwin.
  #     programs.fish.enable = true;

  #     # Set Git commit hash for darwin-version.
  #     system.configurationRevision = self.rev or self.dirtyRev or null;

  #     # Used for backwards compatibility, please read the changelog before changing.
  #     # $ darwin-rebuild changelog
  #     system.stateVersion = 6;

  #     # The platform the configuration will be used on.
  #     nixpkgs.hostPlatform = "aarch64-darwin";
  #   };
  # in
  # {
  #   # Build darwin flake using:
  #   # $ darwin-rebuild build --flake .#simple
  #   darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
  #     modules = [ configuration ];
  #   };
  # };
}
