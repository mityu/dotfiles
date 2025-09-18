{ inputs, pkgs, lib, username, ... }:
  let
    runBeforeXfconfSettings = commands:
      # This is a modification of:
      # https://github.com/nix-community/home-manager/blob/6e28513cf2ee9a985c339fcef24d44f43d23456b/modules/misc/xfconf.nix#L154-L169
      let
        load = pkgs.writeShellScript "load-xfconf" commands;
      in
      # The name 'xfconfSettings' is from:
      # https://github.com/nix-community/home-manager/blob/6e28513cf2ee9a985c339fcef24d44f43d23456b/modules/misc/xfconf.nix#L135/bin/xfconf-query
      lib.hm.dag.entryBefore [ "xfconfSettings" ] (
        ''
          if [[ -v DBUS_SESSION_BUS_ADDRESS ]]; then
            export DBUS_RUN_SESSION_CMD=""
          else
            export DBUS_RUN_SESSION_CMD="${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon"
          fi

          run $DBUS_RUN_SESSION_CMD ${load}

          unset DBUS_RUN_SESSION_CMD
        ''
      );
  in
  {
    imports = [
      inputs.nur.modules.homeManager.default
      ./pkgs/vim.nix
      ./linux/xfconf-xfce4-panel.nix
      ./common.nix
    ];

    programs.home-manager.enable = true;
    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";
      stateVersion = "22.11";
    };

    home.packages = with pkgs; [
      bashInteractive
      brightnessctl
      cargo
      discord
      gdb
      gnumake
      gtrash
      hwloc
      nautilus
      rofi
      seahorse
      slack
      # swift
      udisks
      vim
      vim-startuptime
      vscode
      wezterm
    ];

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
          "browser.uiCustomization.state" = builtins.toJSON ({
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
            });
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

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-tty;

      # c.f.: https://wiki.archlinux.jp/index.php/GnuPG#gpg-agent
      defaultCacheTtl = 60480000;
      maxCacheTtl = 60480000;
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
        size = 9;
      };
      # theme = {
      #   package = pkgs.whitesur-gtk-theme;
      #   name = "WhiteSur-Light";
      # };
      iconTheme = {
        package = pkgs.kdePackages.breeze-icons;
        name = "breeze-dark";
      };
      # gtk3.bookmarks = [
      # ];
    };

    # Clean /plugins property before apply this settings because all of the
    # entry in /plugins property of xfce4-panel channel should be completely
    # **replaced**.
    home.activation.xfconfSettingsPre =
      runBeforeXfconfSettings "${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel -p /plugins -r -R";

    # Restart xfce4-panel on reloading configuration.
    # home.activation.xconfSettingsPost = lib.hm.dag.entryAfter [ "xfconfSettings" ] ''
    #   xfce4-panel -r
    # '';

    xfconf-xfce4-panel.plugins.netload.configFile = ''
      Use_Label=true
      Show_Values=true
      Show_Bars=true
      Colorize_Values=false
      Color_In=rgb(255,79,0)
      Color_Out=rgb(53,132,228)
      Text=net
      Network_Device=eno1
      Max_In=4096
      Max_Out=4096
      Auto_Max=false
      Update_Interval=950
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
        pager = {};
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
        actions = {};
        showdesktop = {};
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
      panels = let resize-factor = 1.25 * 1.25; in [
        {
          size = 26 * resize-factor;
          icon-size = 16 * resize-factor;
          position = "p=6;x=0;y=0";
          position-locked = true;
          plugins = plugins: with plugins; [
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
          plugins = plugins: with plugins; [
            separator-expandable
            showdesktop
            tasklist
            separator-expandable
          ];
        }
      ];
    };

    xfconf.settings = {
      xfce4-keyboard-shortcuts = {
        # <Primary> is the CTRL key.
        "commands/custom/<Primary>space" = "xfce4-appfinder";
        "commands/custom/<Super>space" = "xfce4-appfinder";
        "xfwm4/custom/<Super>Tab" = "cycle_windows_key";
        "xfwm4/custom/<Super><Shift>Tab" = "cycle_reverse_windows_key";
        "xfwm4/custom/<Alt>Tab" = "switch_window_key";
        "xfwm4/custom/<Super>Left" = "left_workspace_key";
        "xfwm4/custom/<Super>Right" = "right_workspace_key";
        # "xfwm4/custom/<Super>KP_Left" = "left_workspace_key";
        # "xfwm4/custom/<Super>KP_Right" = "right_workspace_key";
      };
      xfce4-power-manager = {
        "xfce4-power-manager/dpms-on-ac-off" = 35;
        "xfce4-power-manager/dpms-on-ac-sleep" = 30;
      };
      xfce4-screensaver = {
        "saver/idle-activation/delay" = 15;  # Time in minutes to lock screen.
      };
      xfwm4 = {
        "general/button_layout" = "CMHS|O";
        "general/show_dock_shadow" = false;
      };
      xsettings = {
        "Xft/DPI" = 96 * 1.25;
      };
    };
  }

