{ self, inputs, ... }: {
  flake.nixosModules.desktop = { config, pkgs, lib, ... }: {
    networking.firewall.checkReversePath = false;

    # Make Electron/Chromium apps run natively on Wayland instead of XWayland:
    # sharp rendering, correct scaling, and portal-based screen capture for the
    # apps that implement it. The nixpkgs wrappers gate the ozone flags on
    # WAYLAND_DISPLAY too, so this is a no-op in an X11 session.
    #environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      faugus-launcher
      steam
      spotify
      remmina
      nicotine-plus
      vlc
      unrar
      inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      appimage-run
      vesktop

      bottles
      wireguard-tools
      proton-vpn
      freecad
      openscad
      gpu-screen-recorder
      gpu-screen-recorder-gtk
      qbittorrent
      mixxx
      smile
      brave

      virtio-win
      win-spice
    ];

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        runAsRoot = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
        verbatimConfig = ''
          nographics_allow_host_audio = 1
        '';
      };
    };
    programs.virt-manager.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;

    # Transparent hugepages for better VM memory performance
    boot.kernel.sysctl."vm.nr_hugepages" = 0;
    boot.kernelParams = [ "transparent_hugepage=always" ];

    # CPU frequency scaling - allow performance governor
    powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

    # Libvirt QEMU hook for CPU pinning and governor switching
    systemd.services.libvirtd.preStart = ''
      mkdir -p /var/lib/libvirt/hooks
      ln -sf ${pkgs.writeShellScript "qemu-hook" ''
        GUEST_NAME="$1"
        ACTION="$2"

        # Ryzen 5800X: SMT siblings pair as N / N+8 (core 0 = cpu 0,8 ...), NOT adjacently.
        # Must stay in sync with win11's <cputune>.
        # Physical cores 4-7 for VM (8 vcpus)
        VM_CPUS="4-7,12-15"
        # Physical cores 0-3 for host; qemu emulator/iothread pinned to core 0 (0,8)
        HOST_CPUS="0-3,8-11"
        ALL_CPUS="0-15"

        if [ "$ACTION" = "started" ]; then
          # Pin host tasks to host CPUs
          systemctl set-property --runtime -- system.slice AllowedCPUs=$HOST_CPUS
          systemctl set-property --runtime -- user.slice AllowedCPUs=$HOST_CPUS
          systemctl set-property --runtime -- init.scope AllowedCPUs=$HOST_CPUS
          # Set performance governor
          for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "performance" > "$cpu" 2>/dev/null || true
          done
        elif [ "$ACTION" = "stopped" ]; then
          # Restore all CPUs to host
          systemctl set-property --runtime -- system.slice AllowedCPUs=$ALL_CPUS
          systemctl set-property --runtime -- user.slice AllowedCPUs=$ALL_CPUS
          systemctl set-property --runtime -- init.scope AllowedCPUs=$ALL_CPUS
          # Restore schedutil governor
          for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "schedutil" > "$cpu" 2>/dev/null || true
          done
        fi
      ''} /var/lib/libvirt/hooks/qemu
    '';

    users.users.ralle.extraGroups = [
      "libvirtd"
      "kvm"
    ];

    # Samba share for VM music access
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "deskboi";
          "security" = "user";
          "map to guest" = "Bad User";
        };
        music = {
          "path" = "/home/ralle/Music";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = "ralle";
        };
      };
    };

    programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );
    

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };
  };
}
