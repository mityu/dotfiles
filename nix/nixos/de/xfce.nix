{ pkgs, ... }:
{
  imports = [
    ../app/xremap.nix
  ];

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        # enableWaylandSession = platform.Wayland;
      };
    };
    # displayManager.lightdm.enable = true;
  };
  services.displayManager.defaultSession = "xfce";
  services.displayManager.ly.enable = true;

  environment.xfce.excludePackages = with pkgs; [
    xfce4-terminal
  ];

  programs.thunar.plugins = with pkgs; [
    thunar-volman
    thunar-archive-plugin
  ];
}
