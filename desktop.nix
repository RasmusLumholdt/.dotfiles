
{config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    faugus-launcher
    steam
    spotify
    remmina
    vlc
    brave
    appimage-run
    discord
    bottles
  ];

}
