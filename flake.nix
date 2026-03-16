{

  description = "Best Flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, neovim-nightly-overlay, ...} : 
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
    nixosConfigurations = {
      deskboi = lib.nixosSystem {
	inherit system;
	modules = [ 
	  ({ pkgs, ... }: {
            nixpkgs.overlays = [ neovim-nightly-overlay.overlays.default ];
          })
	  ./configuration.nix 
	];
      };
    };
    homeConfigurations = {
      ralle = home-manager.lib.homeManagerConfiguration {
      	inherit pkgs;
	modules = [ ./home.nix ];
      };
    };
  };
}
