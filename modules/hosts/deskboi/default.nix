{ self, inputs, ... }: {
  flake.nixosConfigurations.deskboi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.overlays
      self.nixosModules.deskboiConfiguration
      self.nixosModules.nvidia
      self.nixosModules.desktop
      self.nixosModules.keyboard
      self.nixosModules.develop
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.ralle = self.lib.homeModules.desktopProfile;
      }
    ];
  };
}
