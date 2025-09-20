{ pkgs, ... }@inputs:
let
  lib = pkgs.lib;
  moduleNames =
    let
      files = builtins.readDir ./.;
      basenames = builtins.attrNames files;
    in
    builtins.filter (x: x != "default.nix") basenames;
  importModule =
    name:
    let
      pkgName = lib.strings.removeSuffix ".nix" name;
    in
    {
      ${pkgName} = (import (./. + "/${name}") inputs);
    };
  modules = builtins.map importModule moduleNames;
in
lib.attrsets.mergeAttrsList modules
