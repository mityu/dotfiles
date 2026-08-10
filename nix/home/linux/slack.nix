{ pkgs, lib, ... }:
let
  slack = pkgs.slack;
in
{
  home.packages = [ slack ];

  systemd.user.services.slack-systray = {
    Unit = {
      Description = "Launch Slack in background on login";
    };
    Service = {
      ExecStart = "${lib.getExe slack} --silent --startup";
    };
    Install = {
      WantedBy = [ "graphical-session.taret" ];
    };
  };
}
