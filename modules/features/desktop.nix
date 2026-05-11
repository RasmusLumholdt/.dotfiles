{ self, inputs, ... }: {
  flake.nixosModules.desktop = { config, pkgs, ... }: {
    networking.firewall.checkReversePath = false;
    environment.systemPackages = with pkgs; [
      faugus-launcher
      steam
      spotify
      remmina
      vlc
      brave
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      appimage-run
      discord
      bottles
      wireguard-tools
      protonvpn-gui
    ];
  };
}
