{
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ./common.nix
  ];

  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "26.05";
  };

  nixpkgs.overlays = [
    # Fix ocamlPackages.camlimages package, which is required by satysfi.
    (
      final: prev:
      let
        ocamlPackages = "ocamlPackages_4_14";
      in
      lib.recursiveUpdate prev {
        ocaml-ng.${ocamlPackages}.camlimages = prev.ocaml-ng.${ocamlPackages}.camlimages.overrideAttrs (o: {
          # Remove the lablgtk package, which causes the build failure on macOS.
          buildInputs = (builtins.filter (p: !(lib.hasInfix "lablgtk" p.name)) o.buildInputs);
        });
      }
    )
  ];

  home.packages = with pkgs; [
    # cabextract
    darwin.trash
    gnupg
    git
    translate-shell
    ott
  ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };
}
