{ self, inputs, ... }: {
  flake.nixosModules.lexicon = { pkgs, ... }:
    let
      version = "1.11.112";

      # Upstream ships a prebuilt Electron tarball that expects an FHS layout,
      # so it cannot run directly on NixOS. Rather than patching the binaries,
      # unpack them verbatim and run them inside an FHS sandbox that supplies
      # the Chromium runtime. Upgrading = bump version + hash.
      src = pkgs.fetchurl {
        url = "https://update.rekord.cloud/releases/lexicon/beta/lexicon-beta-${version}-linux-amd64.tar.gz";
        hash = "sha256-7uuaPVsLmRQGNZiE/3VzbA2bWLb5gETVPu14Jg9Dtg0=";
      };

      unpacked = pkgs.stdenvNoCC.mkDerivation {
        pname = "lexicon-beta-unpacked";
        inherit version src;
        sourceRoot = "lexicon-beta-${version}";
        # The FHS env provides the libraries; patchelf/strip would only corrupt
        # the shipped Electron binaries.
        dontFixup = true;
        installPhase = ''
          runHook preInstall
          mkdir -p "$out"
          cp -r . "$out/"
          runHook postInstall
        '';
      };

      # The shipped .desktop hardcodes Exec=/usr/lib/lexicon-beta/..., so write
      # our own pointing at the wrapper on PATH.
      desktopItem = pkgs.makeDesktopItem {
        name = "lexicon-beta";
        desktopName = "Lexicon";
        comment = "Library management for professional DJs";
        exec = "lexicon %U";
        icon = "lexicon-beta";
        categories = [ "AudioVideo" "Audio" ];
        mimeTypes = [ "x-scheme-handler/lexicon" ];
      };

      lexicon = pkgs.buildFHSEnv {
        name = "lexicon";

        targetPkgs = p: with p; [
          glib nss nspr dbus at-spi2-core at-spi2-atk atk cups expat
          libdrm mesa libgbm libxkbcommon pango cairo alsa-lib
          systemd udev gtk3 gdk-pixbuf
          pipewire pulseaudio
          zlib libglvnd libnotify libsecret
          libx11 libxcomposite libxdamage libxext libxfixes libxrandr
          libxcb libxi libxcursor libxrender libxscrnsaver libxtst libxshmfence
        ];

        runScript = "${unpacked}/lexicon-beta";

        extraInstallCommands = ''
          mkdir -p "$out/share/applications"
          cp -r ${unpacked}/share/icons "$out/share/icons"
          cp ${desktopItem}/share/applications/*.desktop "$out/share/applications/"
        '';

        meta = {
          description = "Lexicon DJ library manager (beta)";
          homepage = "https://www.lexicondj.com/";
          platforms = [ "x86_64-linux" ];
        };
      };
    in
    {
      environment.systemPackages = [ lexicon ];
    };
}
