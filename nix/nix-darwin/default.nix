{ pkgs, username, ... }:
{

  nix = {
    gc = {
      automatic = true;
      interval = {
        Hour = 9;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = "nix-command flakes";
    };
  };

  system = {
    stateVersion = 6; # Do not modify this unless your're certain to change this.
    primaryUser = username;
  };

  programs.fish = {
    enable = true;
    useBabelfish = true;
  };
}
