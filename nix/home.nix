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
    # binutils  # Conflict with clang-tools
    bashInteractive
    cargo
    cmake
    curl
    deno
    efm-langserver
    eza
    firefox
    fish
    gauche
    gdb
    gh
    go
    jq
    libgcc
    llvmPackages_19.clang-tools
    llvmPackages_19.libcxxClang
    ninja
    ocaml
    opam
    ripgrep
    rofi
    skim
    vhs
    vim
    wezterm
    yq-go
  ];

  programs.wezterm = {
    package = inputs.wezterm.packages.${pkgs.system}.default;
    # enable = true;
    # extraConfig = builtins.readFile /home/mityu/dotfiles/wezterm/wezterm.lua;
  };
}
