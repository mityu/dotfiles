{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./module/libinput-gestures.nix ];

  services.libinput-gestures = {
    enable = config.feat.enableLibinputGestures;
    gestures = {
      # xdotool getwindowclassname $(xdotool getwindowfocus)
      # NOTE: On Wayland, Firefox has native support for pinch in/out zooming.
      # Remove these once xfce is ported to Wayland and works on it well.
      # NOTE: Xinput2 may also have similar functionality.
      "pinch out".default = "${lib.getExe pkgs.xdotool} key ctrl+plus";
      "pinch in".default = "${lib.getExe pkgs.xdotool} key ctrl+minus";
    };
  };
}
