{ self, inputs, ... }: {

  flake.nixosModules.deskboiHardware = { config, lib, pkgs, modulesPath, ... }:
  {
    imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
    { device = "/dev/disk/by-uuid/4bdc7d27-ad7e-4ead-9796-9bf5754fc774";
      fsType = "ext4";
    };

    fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F4B1-7195";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    swapDevices =
    [ { device = "/dev/disk/by-uuid/ca6a893c-bd13-4751-969a-931b5e9ab66f"; }
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
