{
  pkgs,
  inputs,
  username,
  ...
}:
let
  uutils-coreutils = import ./pkgs/uutils-coreutils.nix { inherit pkgs; };
  vimExtraPackages = with pkgs; [
    bash-language-server
    coqPackages.coq-lsp
    efm-langserver
    fish-lsp
    gopls
    haskell-language-server
    lua-language-server
    nixd
    ocamlPackages.ocaml-lsp
    rust-analyzer
    texlab
    tinymist
  ];
in
{
  imports = [
    ./pkgs/vim-overlay.nix
    ./pkgs/vim-wrapper.nix
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
      eza
      fd
      fish
      gauche
      gh
      ghc
      ghq
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
      tokei
      typst
      vhs
      yazi
      yq-go
    ]
    ++ [ (lib.hiPrio uutils-coreutils) ];

  programs.myvim = {
    enable = true;
    extraPackages = vimExtraPackages;
  };
  programs.neovim = {
    enable = true;
    extraPackages = vimExtraPackages;
  };
}
