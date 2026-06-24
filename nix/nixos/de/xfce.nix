{ pkgs, lib, ... }:
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

  environment.pathsToLink = lib.warn ''
    Adding `/etc/xdg` to `environment.pathsToLink` as a workaround to deal with startup failure of XFCE4.
    It maybe due to a break change that stops linking the `/etc/xdg` directory automatically.
    The change is introduced in: https://github.com/NixOS/nixpkgs/pull/530382
    And maybe related (may reverts the above): https://github.com/NixOS/nixpkgs/pull/533416

    It is left for a future task that what should be actually linked.
    Notes for the future: xfce4-session package have /etc/xdg files.
  '' [ "/etc/xdg" ];
}
