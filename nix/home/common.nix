{ pkgs, inputs, username, ... }:
let
  uutils-coreutils = import ./pkgs/uutils-coreutils.nix { inherit pkgs; };
in
{
  imports = [
    ./pkgs/vim.nix
  ];

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];

  programs.home-manager.enable = true;
  home = {
    username = "${username}";
    stateVersion = "22.11";
  };

  home.packages =
    with pkgs;
    [
      bat
      btop
      cmake
      comma
      curl
      deno
      efm-langserver
      eza
      fd
      fish
      gauche
      gh
      ghc
      go
      gcc
      hyperfine
      jq
      # libgcc  # FIXME: I don't know why but this cause build failure on darwin.
      (lib.hiPrio clang-tools)
      (lib.hiPrio llvmPackages.libcxxClang)
      llvmPackages.mlir
      lua
      ninja
      nixfmt-rfc-style
      ocaml
      opam
      ripgrep
      rlwrap
      serie
      skim
      stylua
      tdf
      tlrc
      tinymist
      tokei
      typst
      vhs
      yazi
      yq-go
    ]
    ++ [ (lib.hiPrio uutils-coreutils) ];

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      lua-language-server
      gopls
      nixd
    ];
  };
}
