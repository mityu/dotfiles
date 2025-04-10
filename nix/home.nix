{ inputs, pkgs, ... }:
let username = "mityu"; in
let
  vim-overlay = final: prev:
    let
      overlayed = inputs.vim-overlay.overlays.features {
        compiledby = "${username}-nix";
        python3 = true;
      } final prev;
    in
    {
      # Enable GUI and clipboards
      vim = overlayed.vim.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
          pkgs.gtk3
          pkgs.xorg.libXmu
          pkgs.xorg.libXpm
        ];
        configureFlags = (oldAttrs.configureFlags or [ ]) ++ [
          "--enable-gui"
        ];
      });
    };
in
{
  nixpkgs = {
    overlays = [
      vim-overlay
    ];
  };

  imports = [ inputs.nur.modules.homeManager.default ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "22.11";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    bat
    bashInteractive
    brightnessctl
    btop
    cargo
    cmake
    curl
    deno
    discord
    efm-langserver
    eza
    fd
    fish
    gauche
    gcc
    gdb
    gh
    ghc
    gnumake
    go
    gtrash
    hwloc
    hyperfine
    jq
    libgcc
    (lib.hiPrio clang-tools)
    (lib.hiPrio llvmPackages.libcxxClang)
    llvmPackages.mlir
    lua
    nautilus
    networkmanagerapplet
    ninja
    ocaml
    opam
    pasystray
    ripgrep
    rlwrap
    rofi
    serie
    skim
    slack
    stylua
    # swift
    tdf
    tinymist
    tokei
    typst
    vhs
    vim
    vim-startuptime
    vscode
    wezterm
    yazi
    yq-go
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
