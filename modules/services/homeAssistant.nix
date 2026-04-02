{ self, inputs, ... }: {
  flake.nixosModules.homeAssistant = { config, pkgs, ... }: {
    networking.firewall.allowedTCPPorts = [ 8123 ]; 
    virtualisation.oci-containers.containers.homeassistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    autoStart = true;

      environment = {
    TZ = "Europe/Copenhagen";
  };

  volumes = [
    "/var/lib/homeassistant:/config"
    "/etc/localtime:/etc/localtime:ro"
    "/run/dbus:/run/dbus:ro"
  ];

  extraOptions = [
    "--network=host"
    "--cap-add=NET_ADMIN"
    "--cap-add=NET_RAW"
  ];
  };

  };
}
