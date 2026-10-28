{ self, inputs, ... }: {
  flake.nixosModules.homeAssistant = { config, pkgs, ... }: {
    networking.firewall = {
      # 8095 = Music Assistant web UI/API, 8097 = its audio stream server
      allowedTCPPorts = [ 1880 1883 3000 8095 8097 8123 9925 ];
      trustedInterfaces = [ "eno1" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/node-red 0750 1000 1000 -"
      "d /var/lib/music-assistant 0750 root root -"
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
            - Music Assistant:
                href: http://192.168.0.107:8095
                description: Music library and players
        - Food:
            - Mealie:
                href: https://mealie.nummi.dk
                description: Recipes and meal planning
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

    virtualisation.oci-containers.containers.music-assistant = {
      image = "ghcr.io/music-assistant/server:latest";
      autoStart = true;

      environment = {
        TZ = "Europe/Copenhagen";
        LOG_LEVEL = "info";
      };

      volumes = [
        "/var/lib/music-assistant:/data"
      ];

      extraOptions = [
        # host network is required for mDNS discovery of Chromecast/Sonos/AirPlay
        "--network=host"
        # needed to read SMB/NFS-mounted music libraries
        "--cap-add=DAC_READ_SEARCH"
        "--security-opt=apparmor:unconfined"
      ];
    };

    virtualisation.oci-containers.containers.node-red = {
      image = "nodered/node-red:latest";
      autoStart = true;

      volumes = [
        "/var/lib/node-red:/data"
      ];

      environment = {
        TZ = "Europe/Copenhagen";
      }; 
      extraOptions = [
        "--network=host"
      ];
    };

    virtualisation.oci-containers.containers.mealie = {
      image = "ghcr.io/mealie-recipes/mealie:latest";
      autoStart = true;
      ports = [ "9925:9000" ];

      environment = {
        TZ = "Europe/Copenhagen";
        BASE_URL = "https://mealie.nummi.dk";
        ALLOW_SIGNUP = "false";
      };

      volumes = [
        "/var/lib/mealie:/app/data"
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
        "/etc/homepage/settings.yaml:/app/config/settings.yaml:ro"
        "/etc/homepage/services.yaml:/app/config/services.yaml:ro"
        "/etc/homepage/docker.yaml:/app/config/docker.yaml:ro"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
    };

  };
}
