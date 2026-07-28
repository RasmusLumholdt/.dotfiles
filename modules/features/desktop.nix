{ self, inputs, ... }: {
  flake.nixosModules.desktop = { config, pkgs, lib, ... }: {
    networking.firewall.checkReversePath = false;
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
      discord
      bottles
      wireguard-tools
      proton-vpn

      virtio-win
      win-spice
    ];

    programs.kdeconnect.enable = true;

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

        # CPU cores 4-15 (cores 2-7, both threads) for VM
        VM_CPUS="4-15"
        # CPU cores 0-3 (cores 0-1, both threads) for host
        HOST_CPUS="0-3"
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
