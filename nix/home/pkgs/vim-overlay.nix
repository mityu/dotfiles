{
  inputs,
  pkgs,
  lib,
  username,
  config,
  ...
}:
let
  inherit (config.feat) platform;
  vim-overlay =
    final: prev:
    let
      overlayed = inputs.vim-overlay.overlays.features {
        compiledby = "${username}-nix";
        python3 = true;
      } final prev;
      vim-nightly = overlayed.vim.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
          pkgs.wayland-scanner
        ];
        buildInputs =
          (oldAttrs.buildInputs or [ ])
          ++ lib.optionals platform.X11 [
            # Enable GUI and clipboards
            pkgs.gtk3
            pkgs.libXmu
            pkgs.libXpm
          ];
        configureFlags = (oldAttrs.configureFlags or [ ]) ++ [
          "--enable-gui"
        ];
      });
    in
    {
      vim = vim-nightly;
    };
in
{
  nixpkgs.overlays = [ vim-overlay ];
}
