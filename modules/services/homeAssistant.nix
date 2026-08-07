{ self, inputs, ... }: {
  flake.nixosModules.homeAssistant = { config, pkgs, ... }: {
    networking.firewall = {
      allowedTCPPorts = [ 1880 8123 ];
      trustedInterfaces = [ "eno1" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/node-red 0750 1000 1000 -"
    ];

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

    virtualisation.oci-containers.containers.node-red = {
      image = "nodered/node-red:latest";
      autoStart = true;

      volumes = [
        "/var/lib/node-red:/data"
      ];

      extraOptions = [
        "--network=host"
      ];
    };

  };
}
