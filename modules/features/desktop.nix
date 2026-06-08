{ self, inputs, ... }: {
  flake.nixosModules.desktop = { config, pkgs, ... }: {
    networking.firewall.checkReversePath = false;
    environment.systemPackages = with pkgs; [
      faugus-launcher
      steam
      spotify
      remmina
      nicotine-plus
      vlc
      brave
      inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      appimage-run
      discord
      bottles
      wireguard-tools
      proton-vpn
    ];
    programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };
  };
}
