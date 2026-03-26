{ self, inputs, ... }: {
  flake.nixosConfigurations.deskboi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.overlays
      self.nixosModules.deskboiConfiguration
      self.nixosModules.nvidia
      self.nixosModules.desktop
      self.nixosModules.keyboard
      self.nixosModules.develop
    ];
  };
}
