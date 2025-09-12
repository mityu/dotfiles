{ pkgs, ... }:
  {
    services.xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
    };
    services.displayManager.defaultSession = "xfce";
  }
