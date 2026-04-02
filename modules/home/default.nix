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
        "hb" = "home-manager switch --flake ~/.dotfiles/";
        "nb" = "sudo nixos-rebuild switch --flake ~/.dotfiles/";
      };
    };

    programs.home-manager.enable = true;
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

      matchBlocks = {
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

  # Profiles
  serverProfile = { ... }: {
    imports = [ baseModule gitModule sshModule zellijModule ];
  };

  desktopProfile = { ... }: {
    imports = [ baseModule gitModule sshModule kittyModule zellijModule ];
    home.sessionPath = [ "$HOME/.config/emacs/bin" ];
  };
in {
  # Expose modules for reuse
  flake.lib.homeModules = {
    inherit baseModule gitModule sshModule zellijModule kittyModule;
    inherit serverProfile desktopProfile;
  };

  # Standalone home-manager configuration
  flake.homeConfigurations.ralle = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    modules = [ desktopProfile ];
  };
}
