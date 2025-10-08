{
  pkgs,
  lib,
  xremap,
  platform,
  username,
  ...
}:
let
  buildCompleteFeatureFlags =
    flags:
    flags
    // {
      # Enable "withWlroots" option only when all of the other features are false.
      withWlroots = lib.lists.all (flag: flag == false) (builtins.attrValues flags);
    };
  featureFlags = buildCompleteFeatureFlags {
    withX11 = platform.X11;
    withNiri = platform.NiriWM;
  };
in
{
  imports = [ xremap.nixosModules.default ];

  services.xremap = featureFlags // {
    userName = username;
    serviceMode = if platform.X11 then "system" else "user";
    watch = true;

    # To check application names, run `wmctrl -x -l`
    # To see xremap debug logs, run `journalctl -u xremap`
    config.modmap = [
      {
        name = "Global";
        remap = {
          "CapsLock" = "CTRL_L";
          "Super_L" = {
            held = "Super_L";
            alone = "Muhenkan";
            alone_timeout_millis = 750;
          };
          "Super_R" = {
            held = "Super_R";
            alone = "Henkan";
            alone_timeout_millis = 750;
          };
        };
      }
    ];

    config.keymap = [
      {
        name = "Zotero";
        application.only = [ "Navigator.Zotero" ];
        remap = {
          "Super-f" = "C-f";
          "Super-Shift-f" = "C-Shift-f";
          "Super-w" = "C-w";
          "Super-q" = "C-q";
        };
      }
      {
        name = "Firefox";
        application.only = [ "Navigator.firefox" ];
        remap = {
          "C-Shift-p" = "C-Shift-p";
          "Super-Shift-n" = "C-Shift-p";
          "Super-Shift-p" = "C-Shift-p";
        };
      }
      {
        name = "Browser";
        application.only = [
          "firefox"
          "Navigator.firefox"
          "Google-chrome"
          "Chromium"
          "Vivaldi-stable"
          "Thunar.Thunar"
        ];
        remap = {
          "Super-t" = "C-t";
          "Super-Shift-t" = "C-Shift-t";
          "Super-n" = "C-n";
          "Super-Shift-n" = "C-Shift-n";
          "Super-w" = "C-w";
          "Super-Shift-w" = "C-Shift-w";
          "Super-r" = "C-r";
          "Super-l" = lib.mkIf platform.Xfce "C-l";
          "Super-f" = "C-f";
          "Super-d" = "C-d";
          "Super-y" = "C-h";
          "Super-LeftBrace" = "C-LeftBrace";
          "Super-RightBrace" = "C-RightBrace";
        };
      }
      {
        name = "macOS like";
        application.not = [
          "URxvt"
          "org.wezfurlong.wezterm"
          "org.wezfurlong.wezterm.org.wezfurlong.wezterm"
          "gnome-terminal-server.Gnome-terminal"
          "Alacritty"
          "Gvim"
        ];
        remap = {
          "C-b" = "Left";
          "C-f" = "Right";
          "C-p" = "Up";
          "C-n" = "Down";
          "C-h" = "Backspace";
          "C-d" = "Delete";
          "C-a" = "Home";
          "C-e" = "End";
          "C-m" = "Enter";
          "C-j" = "Enter";
          "C-o" = [
            "Enter"
            "Left"
          ];
          "Super-c" = "C-c";
          "Super-v" = "C-v";
          "Super-a" = "C-a";
        };
      }
      {
        name = "Xfce4-appfinder";
        application.only = [ "xfce4-appfinder.Xfce4-appfinder" ];
        remap = {
          "Control-Space" = "Esc";
        };
      }
      {
        name = "Application specific kill";
        application.only = [
          "Slack"
          "discord"
        ];
        remap = {
          "Super-q" = "C-q";
        };
      }
      {
        name = "M-CR -> C-CR";
        application.only = [ "Slack" ];
        remap = {
          "Super-Enter" = "C-Enter";
        };
      }
      (lib.mkIf platform.Xfce {
        name = "Wezterm Super-Plus";
        application.only = [ "org.wezfurlong.wezterm.org.wezfurlong.wezterm" ];
        remap = {
          "Super-Shift-Equal" = "Super-KPPlus"; # US keyboard
          "Super-Shift-Semicolon" = "Super-KPPlus"; # JIS keyboard
        };
      })
      {
        name = "Window manager's kill";
        remap = {
          "Super-q" = lib.mkIf platform.X11 {
            launch = [
              "${lib.getExe pkgs.xdotool}"
              "getactivewindow"
              "windowclose"
            ];
          };
        };
      }
    ];

  };

  systemd.user.services.set-xhost = lib.mkIf platform.X11 {
    description = "Run a one-shot command upon user login";
    path = [ pkgs.xorg.xhost ];
    wantedBy = [ "default.target" ];
    script = "xhost +SI:localuser:root";
    environment.DISPLAY = ":0.0";
  };
}
