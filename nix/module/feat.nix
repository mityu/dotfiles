{ hardware, desktopEnvironment }:
{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.feat = {
    hardware = mkOption {
      type = types.str;
      default = hardware;
      readOnly = true;
    };

    platform = mkOption {
      type = types.attrs;
      default = (import ../lib/getPlatformInfo.nix) desktopEnvironment;
      readOnly = true;
    };

    isDesktop = mkOption {
      type = types.bool;
      default = lib.strings.hasPrefix "desktop" hardware;
    };

    enableTexPackages = mkOption {
      type = types.bool;
      default = builtins.elem hardware [
        "desktop-endeavor"
        "desktop-b760m-pro"
        "laptop-hp-envy"
      ];
    };
  };
}
