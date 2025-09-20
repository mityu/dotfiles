{ pkgs, ... }:
pkgs.writeShellScriptBin "coreutils" ''
  exec ${pkgs.uutils-coreutils-noprefix}/bin/coreutils "$@"
''
