{
  pkgs,
  lib,
  hardware,
  ...
}:
let
  runBeforeXfconfSettings =
    commands:
    # This is a modification of:
    # https://github.com/nix-community/home-manager/blob/6e28513cf2ee9a985c339fcef24d44f43d23456b/modules/misc/xfconf.nix#L154-L169
    let
      load = pkgs.writeShellScript "load-xfconf" commands;
    in
    # The name 'xfconfSettings' is from:
    # https://github.com/nix-community/home-manager/blob/6e28513cf2ee9a985c339fcef24d44f43d23456b/modules/misc/xfconf.nix#L135/bin/xfconf-query
    lib.hm.dag.entryBefore [ "xfconfSettings" ] ''
      if [[ -v DBUS_SESSION_BUS_ADDRESS ]]; then
        export DBUS_RUN_SESSION_CMD=""
      else
        export DBUS_RUN_SESSION_CMD="${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon"
      fi

      run $DBUS_RUN_SESSION_CMD ${load}

      unset DBUS_RUN_SESSION_CMD
    '';
  reconnect-monitors = import ../pkgs/x11-reconnect-monitors.nix { inherit pkgs; };
  isDesktop = lib.strings.hasPrefix "desktop" hardware;
in
{
  imports = [
    ./module/xfconf-xfce4-desktop-wallpaper.nix
    ./module/xfconf-xfce4-panel.nix
  ];

  # Clean /plugins property before apply this settings because all of the
  # entry in /plugins property of xfce4-panel channel should be completely
  # **replaced**.
  home.activation.xfconfSettingsPre = runBeforeXfconfSettings "${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel -p /plugins -r -R";

  # Restart xfce4-panel on reloading configuration.
  # home.activation.xconfSettingsPost = lib.hm.dag.entryAfter [ "xfconfSettings" ] ''
  #   xfce4-panel -r
  # '';

  # Tips: Run `xfce4-panel -r` to reload configuration (it does restarting xfce4-panel).
  xfconf-xfce4-panel.plugins.netload.configFile =
    let
      networkDevices = {
        desktop-endeavor = "eno1";
        desktop-b760m-pro = "enp4s0";
      };
    in
    ''
      Use_Label=true
      Show_Values=true
      Show_Bars=true
      Colorize_Values=false
      Color_In=rgb(255,79,0)
      Color_Out=rgb(53,132,228)
      Text=net
      Network_Device=${if networkDevices ? ${hardware} then networkDevices.${hardware} else "wlo1"}
      Max_In=4096
      Max_Out=4096
      Auto_Max=true
      Update_Interval=1000
      Values_As_Bits=false
      Digits=2
    '';

  xfconf-xfce4-panel = {
    dark-mode = false;
    plugins = {
      applications-menu = {
        name = "applicationsmenu";
        attrs.style = 0;
      };
      tasklist = {
        attrs = {
          grouping = 1;
          sort-order = 0;
        };
      };
      separator = {
        attrs.style = 0;
      };
      separator-expandable = {
        name = "separator";
        attrs = {
          expand = true;
          style = 0;
        };
      };
      pager = { };
      systray = {
        attrs.square-icons = true;
      };
      clock = {
        attrs = {
          digital-layout = 3;
          digital-time-font = "Sans 10";
          digital-time-format = "%m/%d(%a) %H:%M";
        };
      };
      actions = { };
      showdesktop = { };
      pulseaudio = {
        attrs.enable-keyboard-shortcuts = true;
      };
      notification = {
        name = "notification-plugin";
      };
      power-manager = {
        name = "power-manager-plugin";
      };
      systemload = {
        package = pkgs.xfce.xfce4-systemload-plugin;
        attrs = {
          uptime.enabled = false;
          network.enabled = false;
        };
      };
      netload = {
        package = pkgs.xfce.xfce4-netload-plugin;
      };
    };
    panels =
      let
        resize-factor = 1.25 * 1.25;
      in
      [
        {
          size = 26 * resize-factor;
          icon-size = 16 * resize-factor;
          position = "p=6;x=0;y=0";
          position-locked = true;
          plugins =
            plugins: with plugins; [
              applications-menu
              separator
              pager
              separator-expandable
              systemload
              netload
              pulseaudio
              systray
              power-manager
              notification
              clock
              separator
              actions
              separator
            ];
        }
        {
          size = 48 * 1.25;
          length = 100;
          autohide-behavior = 1;
          position = "p=10;x=0;y=0";
          position-locked = true;
          plugins =
            plugins: with plugins; [
              separator-expandable
              showdesktop
              tasklist
              separator-expandable
            ];
        }
      ];
  };

  xfconf-xfce4-desktop-wallpaper =
    let
      wallpapers = import ../pkgs/wallpapers.nix { inherit pkgs; };
    in
    {
      workspace0 =
        if hardware == "laptop-hp-envy" then
          "${wallpapers}/fgo-lady-avalon-MNe.jpg"
        else
          "${wallpapers}/mahoyo-misakicho.jpeg";
    };

  xfconf.settings = {
    # Note that `xfwm4 -r` command may helpful to check the effects of configuration changes.
    xfce4-keyboard-shortcuts = {
      # <Primary> is the CTRL key.
      "commands/custom/<Super>p" = null;
      "commands/custom/override" = true;
      "commands/custom/<Primary>space" = "xfce4-appfinder";
      "commands/custom/<Super>space" = "xfce4-appfinder";
      "commands/custom/<Super><Shift>2" = "xfce4-screenshooter";
      "commands/custom/<Super><Shift>3" = "xfce4-screenshooter --fullscreen";
      "commands/custom/<Super><Shift>4" = "xfce4-screenshooter --region";
      "commands/custom/<Super><Shift>5" = "xfce4-screenshooter --window";
      "commands/custom/<Super><Primary><Shift>3" = "xfce4-screenshooter --clipboard --fullscreen";
      "commands/custom/<Super><Primary><Shift>4" = "xfce4-screenshooter --clipboard --region";
      "commands/custom/<Super><Primary><Shift>5" = "xfce4-screenshooter --clipboard --window";
      "commands/custom/<Super>F12" = "${reconnect-monitors}";
      "xfwm4/custom/<Primary><Alt>Left" = null;
      "xfwm4/custom/<Primary><Alt>Right" = null;
      "xfwm4/custom/override" = true;
      "xfwm4/custom/<Super>Tab" = "cycle_windows_key";
      "xfwm4/custom/<Super><Shift>Tab" = "cycle_reverse_windows_key";
      "xfwm4/custom/<Alt>Tab" = "switch_window_key";
      "xfwm4/custom/<Super>Left" = "left_workspace_key";
      "xfwm4/custom/<Super>Right" = "right_workspace_key";
      "xfwm4/custom/<Super><Primary>Left" = "tile_left_key";
      "xfwm4/custom/<Super><Primary>Right" = "tile_right_key";
    };
    xfce4-power-manager =
      if isDesktop then
        {
          "xfce4-power-manager/dpms-on-ac-off" = 80;
          "xfce4-power-manager/dpms-on-ac-sleep" = 75;
        }
      else
        {
          "xfce4-power-manager/dpms-on-ac-off" = 35;
          "xfce4-power-manager/dpms-on-ac-sleep" = 30;
        };
    xfce4-screensaver =
      if isDesktop then
        {
          "saver/idle-activation/delay" = 60; # Time in minutes to lock screen.
        }
      else
        {
          "saver/idle-activation/delay" = 15; # Time in minutes to lock screen.
        };
    xfwm4 = {
      "general/button_layout" = "CMHS|O";
      "general/show_dock_shadow" = false;
      "general/raise_with_any_button" = false;
    };
    xsettings = {
      "Xft/DPI" = 96 * 1.25;
    };
  };
}
