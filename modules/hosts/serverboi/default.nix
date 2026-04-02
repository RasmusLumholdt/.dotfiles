{ self, inputs, ... }: {
  flake.nixosConfigurations.serverboi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.serverboiConfiguration
      self.nixosModules.keyboard
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.ralle = self.lib.homeModules.serverProfile;
      }
    ];
  };
}
