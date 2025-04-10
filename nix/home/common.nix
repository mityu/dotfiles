{ pkgs, ... }:
  {
    home.packages = with pkgs; [
      bat
      btop
      cmake
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
      libgcc
      (lib.hiPrio clang-tools)
      (lib.hiPrio llvmPackages.libcxxClang)
      llvmPackages.mlir
      lua
      ninja
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
    ];
  }
