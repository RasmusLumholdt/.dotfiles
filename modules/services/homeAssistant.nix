{ self, inputs, ... }: {
  flake.nixosModules.homeAssistant = { config, pkgs, ... }: {
    networking.firewall = {
      allowedTCPPorts = [ 1880 1883 3000 8123 ];
      trustedInterfaces = [ "eno1" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/node-red 0750 1000 1000 -"
    ];

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          address = "0.0.0.0";
          port = 1883;
          omitPasswordAuth = true;
          acl = [ "topic readwrite #" ];
        }
      ];
    };

    environment.etc = {
      "homepage/settings.yaml".text = ''
        title: serverboi
      '';

      "homepage/services.yaml".text = ''
        - Home Automation:
            - Home Assistant:
                href: http://192.168.0.107:8123
                description: Home automation
            - Node-RED:
                href: http://192.168.0.107:1880
                description: Automations
            - MQTT:
                description: Mosquitto broker on port 1883
        - Infrastructure:
            - Docker:
                widget:
                  type: docker
                  server: my-docker
      '';

      "homepage/docker.yaml".text = ''
        my-docker:
          socket: /var/run/docker.sock
      '';
    };

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

    virtualisation.oci-containers.containers.homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      autoStart = true;
      ports = [ "3000:3000" ];

      environment = {
        HOMEPAGE_ALLOWED_HOSTS = "192.168.0.107:3000,serverboi:3000,localhost:3000";
      };

      volumes = [
        "/etc/homepage:/app/config:ro"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
    };

  };
}
