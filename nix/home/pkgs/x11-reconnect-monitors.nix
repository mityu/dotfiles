{ pkgs, ... }:
let
  inherit (pkgs.lib) getExe;
  xrandr = getExe pkgs.xorg.xrandr;
  grep = getExe pkgs.gnugrep;
  awk = getExe pkgs.gawk;
  xargs = "${pkgs.findutils}/bin/xargs";
in
pkgs.writeShellScript "reconnect-monitors" ''
  function main {
    local monitors
    monitors="$(${xrandr} | ${grep} -w connected | ${awk} '{print $1}')"
    echo $monitors | ${xargs} -I{} ${xrandr} --output {} --off
    echo $monitors | ${xargs} -I{} ${xrandr} --output {} --auto
  }
  main
''
