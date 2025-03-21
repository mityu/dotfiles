{ inputs, pkgs, ... }:
let
  vim-overlay = final: prev:
    let
      overlayed = inputs.vim-overlay.overlays.features {
        compiledby = "mityu-nix";
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

  home = rec {
    username = "mityu";
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
    efm-langserver
    eza
    fd
    firefox
    fish
    gauche
    gcc
    gdb
    gh
    ghc
    gnumake
    go
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
    ripgrep
    rlwrap
    rofi
    serie
    skim
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
    # enable = true;
    # extraConfig = builtins.readFile /home/mityu/dotfiles/wezterm/wezterm.lua;
  };

  programs.firefox = {
    profiles.settings = {
      "general.smoothScroll" = true;
    };
  };

  # TODO: audio applet
  systemd.user.services.launch-applets = {
    Unit = {
      Description = "Run a one-shot command upon user login to launch applets";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    ServiceStart = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.whitesur-cursors;
      name = "WhiteSur-cursors";
    };
    font = {
      package = pkgs.noto-fonts-cjk-sans;
      name = "Noto Sans CJK JP";
      size = 14;
    };
    theme = {
      package = pkgs.whitesur-gtk-theme;
      name = "WhiteSur-Light";
    };
    # gtk3.bookmarks = [
    # ];
  };
}
