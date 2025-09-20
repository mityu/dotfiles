platform:
  let
    NiriWM = platform == "niri";
    Xfce = platform == "xfce";
    Wayland = NiriWM || platform == "wayland";
    X11 = Xfce || platform == "x11";
  in
  { inherit X11 Wayland NiriWM Xfce; }
