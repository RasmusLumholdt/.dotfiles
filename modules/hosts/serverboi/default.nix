{ self, inputs, ... }: {
  flake.nixosConfigurations.serverboi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.serverboiConfiguration
      self.nixosModules.keyboard
    ];
  };
}
