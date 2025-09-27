{ pkgs, ... }:
pkgs.writeShellScriptBin "uutils-coreutils" ''
  exec ${pkgs.uutils-coreutils}/bin/uutils-coreutils "$@"
''
