{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./module/libinput-gestures.nix ];

  services.libinput-gestures = {
    enable = true;
    gestures = {
      "pinch out".default = "${lib.getExe pkgs.xdotool} key ctrl+plus";
      "pinch in".default = "${lib.getExe pkgs.xdotool} key ctrl+minus";
    };
  };
}
