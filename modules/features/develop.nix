{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    devShells.platformio = pkgs.mkShell {
      packages = with pkgs; [
        platformio
        arduino-cli
        clang-tools
      ];
    };
  };

  flake.nixosModules.develop = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      emacs
      opencode
      lazygit
      dotnet-sdk
      tree-sitter
      arduino-cli
      bruno
    ];
  };
}
