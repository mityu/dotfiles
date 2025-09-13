{ pkgs, windowManager, ... }:
  {
    services.xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          enableWaylandSession = windowManager.Wayland;
        };
      };
      displayManager.lightdm.enable = true;
    };
    services.displayManager.defaultSession = "xfce";

    environment.xfce.excludePackages = with pkgs; [
      xfce.xfce4-terminal
    ];
  }
