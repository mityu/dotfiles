{
  inputs,
  pkgs,
  lib,
  username,
  config,
  ...
}:
let
  inherit (config.feat) platform isDesktop enableTexPackages;
in
{
  imports = [
    inputs.nur.modules.homeManager.default
    ./linux/fcitx5.nix
    ./linux/firefox.nix
    ./linux/xfce4.nix
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
      file
      gdb
      gnumake
      gtrash
      hwloc
      imagemagick
      libgcc
      net-tools
      ollama
      rofi
      seahorse
      slack
      # swift
      tree
      udisks
      vscode
      wezterm
      (lib.mkIf (!platform.Xfce) nautilus)
      (lib.mkIf (platform.X11) xsel)
    ]
    ++ map (v: lib.mkIf enableTexPackages v) [
      pkgs.texliveFull
      pkgs.kdePackages.okular
      (import ./pkgs/ott.nix {
        inherit (inputs) opam-nix;
        inherit (pkgs) system;
      })
      pkgs.zotero
    ]
    ++ [
      remmina
      zoom-us
    ];

  programs.wezterm = {
    package = inputs.wezterm.packages.${pkgs.system}.default;
  };

  services.blueman-applet.enable = isDesktop;

  services.kdeconnect = {
    enable = true;
    indicator = true;
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

  xdg.mimeApps = {
    defaultApplications = {
    };
    associations.added =
      lib.pipe
        [ "jpeg" "png" "bmp" "apng" "heif" ]
        [
          (map (type: "image/${type}"))
          (
            mime-types:
            lib.genAttrs mime-types (_: [
              "org.xfce.ristretto.desktop"
              "org.kde.okular.desktop"
            ])
          )
        ];
  };
}
