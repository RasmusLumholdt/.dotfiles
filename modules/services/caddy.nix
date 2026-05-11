
{ self, inputs, ... }: {
  flake.nixosModules.caddy = { config, pkgs, ... }: {
    networking.firewall.allowedTCPPorts = [ 80 443 ]; 
    
    services.caddy = {
      enable = true;
      virtualHosts."ha.nummi.dk".extraConfig = ''
      reverse_proxy 127.0.0.1:8123
      '';

      virtualHosts."abooks.nummi.dk".extraConfig = ''
      reverse_proxy 127.0.0.1:13378
      '';
    };
  };
}
