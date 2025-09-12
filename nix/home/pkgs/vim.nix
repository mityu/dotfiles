{ inputs, pkgs, username, ... }:
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
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
            pkgs.wayland-scanner
          ];
          buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
            # TODO: Check X11 or wayland
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
  }
