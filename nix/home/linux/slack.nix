{ pkgs, lib, ... }:
let
  slack = pkgs.slack;
in
{
  home.packages = [ slack ];

  xdg.configFile."autostart/slack-systray.desktop".text = lib.generators.toINI { } {
    "Desktop Entry" = {
      Name = "Slack";
      Comment = "Launch Slack in background";
      Exec = "${lib.getExe slack} --silent --startup";
      Terminal = false;
      Type = "Application";
      Hidden = false;
    };
  };
}
