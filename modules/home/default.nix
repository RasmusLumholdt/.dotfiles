{ self, inputs, ... }:
let
  # Shared home-manager modules
  baseModule = {
    home.username = "ralle";
    home.homeDirectory = "/home/ralle";
    home.stateVersion = "25.11";
    home.enableNixpkgsReleaseCheck = false;

    programs.bash = {
      enable = true;
      shellAliases = {
        ll = "ls -l";
        ".." = "cd ..";
        "n" = "nvim";
        "hb" = "home-manager switch --flake ~/.dotfiles/";
        "nb" = "sudo nixos-rebuild switch --flake ~/.dotfiles/";
      };
    };

    programs.home-manager.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      shellWrapperName = "y";
    };
  };

  gitModule = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "RasmusLumholdt";
        user.email = "dev.rlumhold@gmail.com";
        init.defaultBranch = "master";
      };
    };
  };

  sshModule = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = [ "~/.ssh/id_ed25519" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };

        "github-work" = {
          hostname = "github.com";
          user = "git";
          identityFile = [ "~/.ssh/id_ed25519_work" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
      };
    };
  };

  zellijModule = {
    programs.zellij = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        attach_to_session = true;
      };
    };
  };

  kittyModule = {
    programs.kitty = {
      enable = true;
      settings = {
        cursor_trail = 3;
        background_opacity = "0.5";
        background_blur = 5;
        dynamic_background_opacity = true;
        window_padding_width = 10;
      };
    };
  };

  # Vesktop's own "Start With System" toggle writes an autostart entry pointing at
  # process.execPath, which on NixOS is the *unwrapped* electron binary. Launching
  # that directly skips the wrapper that exports GIO_EXTRA_MODULES, XDG_DATA_DIRS,
  # GDK_PIXBUF_MODULE_FILE etc., and electron dies with SIGILL a few hundred ms in.
  # Own the file declaratively so it always points at the wrapper.
  vesktopModule = { pkgs, ... }: {
    xdg.configFile."autostart/vesktop.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Vesktop
      Comment=Vesktop autostart script
      Exec=${pkgs.vesktop}/bin/vesktop
      StartupNotify=false
      Terminal=false
      Icon=vesktop
    '';
  };

  # Profiles
  serverProfile = { ... }: {
    imports = [ baseModule gitModule sshModule zellijModule ];
  };

  desktopProfile = { ... }: {
    imports = [ baseModule gitModule sshModule kittyModule vesktopModule ];
    home.sessionPath = [ "$HOME/.config/emacs/bin" ];
  };
in {
  # Expose modules for reuse
  flake.lib.homeModules = {
    inherit baseModule gitModule sshModule zellijModule kittyModule vesktopModule;
    inherit serverProfile desktopProfile;
  };

  # Standalone home-manager configuration
  flake.homeConfigurations.ralle = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    modules = [ desktopProfile ];
  };
}
