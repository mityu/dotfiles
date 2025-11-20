{ pkgs, lib, ... }:
{
  environment.systemPackages = [ pkgs.pasystray ];
  systemd.user.services.pasystray = {
    description = "Run a one-shot command upon user login to launch pasystray";
    wantedBy = [ "default.target" ];
    script = lib.getExe pkgs.pasystray;
    environment = {
      DISPLAY = ":0.0";
    };
  };
}
