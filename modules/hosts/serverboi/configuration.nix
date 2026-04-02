
{ self, inputs, ... }: {

  flake.nixosModules.serverboiConfiguration = { config, pkgs, lib, ... }: {
    
      imports =
        [
          self.nixosModules.serverboiHardware
        ];

      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "serverboi"; # Define your hostname.

      # Enable networking
      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "Europe/Copenhagen";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_DK.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "da_DK.UTF-8";
        LC_IDENTIFICATION = "da_DK.UTF-8";
        LC_MEASUREMENT = "da_DK.UTF-8";
        LC_MONETARY = "da_DK.UTF-8";
        LC_NAME = "da_DK.UTF-8";
        LC_NUMERIC = "da_DK.UTF-8";
        LC_PAPER = "da_DK.UTF-8";
        LC_TELEPHONE = "da_DK.UTF-8";
        LC_TIME = "da_DK.UTF-8";
      };

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.ralle = {
        isNormalUser = true;
        description = "Rasmus";
        extraGroups = [ "networkmanager" "wheel" ];
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      programs.neovim = {
        enable = true;
        defaultEditor = true;
      };

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
         git
         ripgrep
         fd
         unzip
         curl
         gcc
         wget
      ];


    programs.nix-ld = {
        enable = true;

        # libs that should be visible to foreign binaries
        libraries = with pkgs; [
          zlib
          openssl
          curl
          # and whatever the foreign binary needs
        ];
      };
      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.11"; # Did you read the comment?

      nix.settings.experimental-features = ["nix-command" "flakes"];
  };

} 
