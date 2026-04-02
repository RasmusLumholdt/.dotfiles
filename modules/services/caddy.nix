
{ self, inputs, ... }: {
  flake.nixosModules.homeAssistant = { config, pkgs, ... }: {
    networking.firewall.allowedTCPPorts = [ 80 443 ]; 
    
    services.caddy = {
  enable = true;
  virtualHosts."ha.nummi.dk".extraConfig = ''
    reverse_proxy 127.0.0.1:8123
  '';
  };
  };
}
