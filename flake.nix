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
    darwinConfigurations."mac-ilya" = nix-darwin.lib.darwinSystem {
      modules = [
        # Import the darwin configuration
        ./darwin.nix
        
        # Import Home Manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ilyalabacheuski = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit self; };
        }
      ];
      specialArgs = { inherit self; };
    };

    # Expose the package set for convenience
    darwinPackages = self.darwinConfigurations."mac-ilya".pkgs;
  };
}