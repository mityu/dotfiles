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
  # See: https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/20
  deno = pkgs.deno.override (
    let
      rp = pkgs.rustPlatform;
    in
    {
      rustPlatform = rp // {
        buildRustPackage =
          args:
          rp.buildRustPackage (
            finalAttrs:
            (args finalAttrs)
            // rec {
              version = "2.5.1";
              src = pkgs.fetchFromGitHub {
                owner = "denoland";
                repo = "deno";
                tag = "v${version}";
                fetchSubmodules = true; # required for tests
                hash = "sha256-W0wQ4SXIAxIBjjk2z3sNTJjAYdY73dDaiPWDeUVWo/w=";
              };
              cargoHash = "sha256-5votu/4MUusRvlZc4+vZQ/wbcI0XSZ8qkq5JaMGJHB8=";
            }
          );
      };
    }
  );
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
