{ self, inputs, ... }: {
  flake.nixosModules.develop = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      emacs
      opencode
      lazygit
      dotnet-sdk
      tree-sitter
    ];
  };
}
