{
  inputs,
  pkgs,
  lib,
  username,
  platform,
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
  enableTexPackages = builtins.elem hardware [
    "desktop-endeavor"
    "desktop-b760m-pro"
  ];
  isDesktop = lib.strings.hasPrefix "desktop" hardware;
in
{
  imports = [
    inputs.nur.modules.homeManager.default
    ./linux/xfconf-xfce4-panel.nix
    ./linux/xfconf-xfce4-desktop-wallpaper.nix
    ./common.nix
  ];

  home = {
    homeDirectory = "/home/${username}";
  };

  home.packages =
    with pkgs;
    [
      bashInteractive
      brightnessctl
      cargo
      discord
      gdb
      gnumake
      gtrash
      hwloc
      libgcc
      rofi
      seahorse
      slack
      # swift
      udisks
      vscode
      wezterm
      (lib.mkIf (!platform.Xfce) nautilus)
    ]
    ++ map (v: lib.mkIf enableTexPackages v) [
      pkgs.texliveFull
      pkgs.papers
      (import ./pkgs/ott.nix {
        inherit (inputs) opam-nix;
        inherit (pkgs) system;
      })
    ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    # enableGtk3 = true;
    fcitx5 = {
      waylandFrontend = with platform; !X11 && Wayland;
      addons = [ pkgs.fcitx5-mozc ];
      settings = {
        # This configuration will be written to "~/.config/fcitx5/config"
        globalOptions = {
          Hotkey = {
            EnumerateWithTriggerKeys = true;
            EnumerateForwardKeys = "";
            EnumerateBackwardKeys = "";
            EnumerateSkipFirst = false;
            ModifierOnlyKeyTimeout = 250;
          };
          "Hotkey/TriggerKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/EnumerateGroupForwardKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/EnumerateGroupBackwardKeys" = {
            "0" = "Shift+Super+space";
          };
          "Hotkey/AltTriggetKeys" = {
            "0" = "Shift_L";
          };
          "Hotkey/ActivateKeys" = {
            "0" = "Henkan";
          };
          "Hotkey/DeactivateKeys" = {
            "0" = "Muhenkan";
          };
          "Hotkey/PrevPage" = {
            "0" = "Up";
          };
          "Hotkey/NextPage" = {
            "0" = "Down";
          };
          "Hotkey/PrevCandidate" = {
            "0" = "Control+P";
            "1" = "Shift+Tab";
          };
          "Hotkey/NextCandidate" = {
            "0" = "Control+N";
            "1" = "Tab";
          };
          "Hotkey/TogglePreedit" = {
            "0" = "Control+Alt+P";
          };
          "Behavior" = {
            ActiveByDefault = false;
            resetStateWhenFocusIn = "No";
            ShareInputState = "No";
            ShowInputMethodInformation = true;
            showInputMethodInformationWhenFocusIn = false;
            CompactInputMethodInformation = true;
            ShowFirstInputMethodInformation = true;
            DefaultPageSize = 5;
            OverrideXkbOption = false;
            CustomXkbOption = "";
            EnabledAddons = "";
            DisabledAddons = "";
            PreloadInputMethod = true;
            AllowInputMethodForPassword = false;

            # Show preedit in application
            PreeditEnabledByDefault = true;

            # Show preedit text when typing password
            ShowPreeditForPassword = false;

            # Interval of saving user data in minutes
            AutoSavePeriod = 30;
          };
        };

        # This configuration will be written to "~/.config/fcitx5/profile"
        inputMethod = {
          GroupOrder = {
            "0" = "Default";
          };
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = "";
          };
        };
      };
    };
  };

  programs.wezterm = {
    package = inputs.wezterm.packages.${pkgs.system}.default;
  };

  programs.firefox = {
    enable = true;
    languagePacks = [ "ja" ];
    profiles.${username} = {
      id = 0;
      isDefault = true;
      settings = {
        "general.smoothScroll" = true;
        "tabs.groups.enabled" = true;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.download.autohideButton" = false;
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "history,bookmarks,syncedtabs,aichat";
        "sidebar.revamp" = true;
        "sidebar.position_start" = false;
        "general.useragent.locale" = "ja";
        "font.language.group" = "ja";
        "font.cjk_pref_fallback_order" = "ja,zh-cn,zh-hk,zh-tw,ko";
        "intl.locale.requested" = "ja,en-US";
        "browser.search.region" = "JP";
        "layout.css.devPixelsPerPx" = 1.25;
        # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            nav-bar = [
              "back-button"
              "forward-button"
              "urlbar-container"
              "vertical-spacer"
              "developer-button"
              "firefox-view-button"
              "alltabs-button"
              "unified-extensions-button"
              "downloads-button"
              "history-panelmenu"
              "preferences-button"
              "sidebar-button"
            ];
          };
        };
      };
      extensions = {
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          ublacklist
        ];
        settings = {
          "@ublacklist".settings = {
            subscriptions = [
              {
                name = "";
                url = "https://raw.githubusercontent.com/108EAA0A/ublacklist-programming-school/main/uBlacklist.txt";
                enabled = true;
              }
            ];
          };
        };
      };
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles.${username} = {
      isDefault = true;
      settings = {
        "general.smoothScroll" = true;
        "layout.css.devPixelsPerPx" = 1.25;
      };
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.whitesur-cursors;
      name = "WhiteSur Cursors";
    };
    font = {
      package = pkgs.noto-fonts-cjk-sans;
      name = "Noto Sans CJK JP";
      size = if platform.Xfce then 10 else 9;
    };
    # theme = {
    #   package = pkgs.whitesur-gtk-theme;
    #   name = "WhiteSur-Light";
    # };
    iconTheme = {
      package = pkgs.callPackage (
        { }:
        pkgs.runCommand "cached-breeze-icons"
          {
            nativeBuildInputs = [ pkgs.kdePackages.breeze-icons ];
          }
          ''
            mkdir -p $out
            # install -Dm555 -d ${pkgs.kdePackages.breeze-icons}/share $out/
            pushd ${pkgs.kdePackages.breeze-icons}
            ${pkgs.lib.getExe pkgs.fd} . --type f \
                --exec install -Dm666 "{}" "$out/{}" \;
            popd
            ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t $out/share/icons/breeze/
            ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t $out/share/icons/breeze-dark/
          ''
      ) { };
      name = if platform.Xfce then "breeze" else "breeze-dark";
    };
    # gtk3.bookmarks = [
    # ];
  };

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
      wallpapers = import ./pkgs/wallpapers.nix { inherit pkgs; };
    in
    {
      workspace0 =
        if hardware == "laptop-hp-envy" then
          "${wallpapers}/fgo-lady-avalon-oz-2.jpg"
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
      "commands/custom/<Super><Primary>2" = "xfce4-screenshooter";
      "commands/custom/<Super><Primary>3" = "xfce4-screenshooter --fullscreen";
      "commands/custom/<Super><Primary>4" = "xfce4-screenshooter --region";
      "commands/custom/<Super><Primary>5" = "xfce4-screenshooter --window";
      "commands/custom/<Super><Primary><Shift>3" = "xfce4-screenshooter --clipboard --fullscreen";
      "commands/custom/<Super><Primary><Shift>4" = "xfce4-screenshooter --clipboard --region";
      "commands/custom/<Super><Primary><Shift>5" = "xfce4-screenshooter --clipboard --window";
      "xfwm4/custom/<Primary><Alt>Left" = null;
      "xfwm4/custom/<Primary><Alt>Right" = null;
      "xfwm4/custom/override" = true;
      "xfwm4/custom/<Super>Tab" = "cycle_windows_key";
      "xfwm4/custom/<Super><Shift>Tab" = "cycle_reverse_windows_key";
      "xfwm4/custom/<Alt>Tab" = "switch_window_key";
      "xfwm4/custom/<Super>Left" = "left_workspace_key";
      "xfwm4/custom/<Super>Right" = "right_workspace_key";
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
