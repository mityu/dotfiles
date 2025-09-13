{ inputs, pkgs, username, ... }:
{
  imports = [
    inputs.nur.modules.homeManager.default
    ./pkgs/vim.nix
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
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "history,bookmarks,syncedtabs,aichat";
        "sidebar.revamp" = true;
        "sidebar.position_start" = false;
        "general.useragent.locale" = "ja";
        "font.language.group" = "ja";
        "font.cjk_pref_fallback_order" = "ja,zh-cn,zh-hk,zh-tw,ko";
        "layout.css.devPixelsPerPx" = 1.25;
        # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
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

  xfconf.settings = {
    xfce4-panel = {
      "panels/dark-mode" = false;
      "panels/panel-1/size" = 26 * 1.25;
      "panels/panel-1/icon-size" = 16 * 1.25;
      "panels/panel-2/size" = 48 * 1.25;
    };
    xfce4-keyboard-shortcuts = {
      # <Primary> is the CTRL key.
      "commands/custom/<Primary>space" = "xfce4-appfinder";
      "commands/custom/<Super>space" = "xfce4-appfinder";
      "xfwm4/custom/<Super>Tab" = "cycle_windows_key";
      "xfwm4/custom/<Super><Shift>Tab" = "cycle_reverse_windows_key";
      "xfwm4/custom/<Alt>Tab" = "switch_window_key";
      "xfwm4/custom/<Super>Left" = "left_workspace_key";
      "xfwm4/custom/<Super>Right" = "right_workspace_key";
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

