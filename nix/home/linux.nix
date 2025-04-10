{ inputs, pkgs, username, ... }@allInputs:
{
  imports = [
    inputs.nur.modules.homeManager.default
    (import ./pkgs/vim.nix allInputs)
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
    networkmanagerapplet
    pasystray
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

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "Run a one-shot command upon user login to launch nm-applet";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
      Environment = [ "DISPLAY=:0.0" ];
    };
  };

  systemd.user.services.pasystray = {
    Unit = {
      Description = "Run a one-shot command upon user login to launch pasystray";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.pasystray}/bin/pasystray";
      Environment = [ "DISPLAY=:0.0" ];
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
}

