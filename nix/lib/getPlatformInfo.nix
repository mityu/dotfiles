platform:
  let
    NiriWM = platform == "niri";
    Wayland = NiriWM || platform == "wayland";
    X11 = platform == "x11";
  in
  { inherit X11 Wayland NiriWM; }
