{ self, inputs, ... }: {
  flake.nixosModules.nvidia = { config, pkgs, ... }: {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      open = true;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      nvidiaPersistenced = true;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    boot.kernelParams = [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_UsePageAttributeTable=1"
    ];
  };
}
