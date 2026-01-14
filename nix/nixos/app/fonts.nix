# Load all font package definition of fonts/*.nix, and put them into `pkgs`.
{ pkgs, lib, ... }@allInputs:
let
  fontpkgs = lib.pipe ./fonts [
    builtins.readDir
    (lib.filterAttrs (_: v: v == "regular"))
    builtins.attrNames
    (map (filename: {
      name = lib.strings.removeSuffix ".nix" filename;
      value = import (./fonts + "/${filename}") allInputs;
    }))
    builtins.listToAttrs
  ];
in
{
  nixpkgs.overlays = [ (_: _: fontpkgs) ];
}
