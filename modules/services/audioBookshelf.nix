

{ self, inputs, ... }: {
  flake.nixosModules.audioBookshelf = { config, pkgs, ... }: {
  
      services.audiobookshelf = {
        enable = true;
        user = "audiobookshelf";
        group = "audiobookshelf";
        dataDir = "audiobookshelf";
        port = 13378;
      };
  };
}
