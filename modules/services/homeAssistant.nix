
{ self, inputs, ... }: {
  flake.nixosModules.homeAssistant = { config, pkgs, ... }: {

      services.home-assistant = {
      enable = true;
      openFirewall = true;
      config = {
        default_config = {};

        homeassistant = {
          name = "Home";
          time_zone = "Europe/Copenhagen";
          unit_system = "metric";
        };

        http = {
          server_host = "0.0.0.0";
        };
      };
  };
  };
}
