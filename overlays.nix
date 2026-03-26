{ self, inputs, ... }: {
  flake.nixosModules.overlays = { ... }: {
    nixpkgs.overlays = [ inputs.neovim-nightly.overlays.default ];
  };
}
