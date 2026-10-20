{ ... }: {
  # SolidCraft is not in nixpkgs. Upstream has its own flake, but it builds from
  # source with no binary cache, so a rebuild means a full Rust compile. Wrap the
  # official AppImage release instead; hashes are the ones published in that
  # release's SHA256SUMS.txt.
  perSystem = { pkgs, lib, system, ... }: {
    packages = lib.optionalAttrs (lib.hasSuffix "-linux" system) {
      solidcraft =
        let
          pname = "solidcraft";
          version = "0.16.2";
          arch = lib.head (lib.splitString "-" system);

          src = pkgs.fetchurl {
            url = "https://github.com/tangency-labs/solidcraft/releases/download/v${version}/solidcraft-${version}-linux-${arch}.AppImage";
            hash = {
              x86_64-linux = "sha256-GS8s6ALuTdR02o9PKk7WBJLhe+CKC7rc4/OwSzm5B7g=";
              aarch64-linux = "sha256-A0n0ZYHiVm6Ehx5FUHGHWfSweTdPCcQQY5mzEU2WH34=";
            }.${system};
          };

          appdir = pkgs.appimageTools.extract { inherit pname version src; };
        in
        pkgs.appimageTools.wrapType2 {
          inherit pname version src;

          # The AppRun copies a .desktop entry and icons into ~/.local/share on
          # every launch so Wayland can resolve the dock icon. We install those
          # into the store instead, so opt out of the stateful copy.
          profile = "export SOLIDCRAFT_NO_DESKTOP_INTEGRATION=1";

          extraInstallCommands = ''
            install -Dm444 ${appdir}/usr/share/applications/ai.storyteller.solidcraft.desktop \
              -t $out/share/applications
            install -Dm444 ${appdir}/usr/share/mime/packages/ai.storyteller.solidcraft.xml \
              -t $out/share/mime/packages
            cp -r ${appdir}/usr/share/icons $out/share/icons
          '';

          meta = {
            description = "Parametric 3D CAD application built in pure Rust";
            homepage = "https://github.com/tangency-labs/solidcraft";
            license = lib.licenses.asl20;
            platforms = [ "x86_64-linux" "aarch64-linux" ];
            mainProgram = pname;
          };
        };
    };
  };
}
