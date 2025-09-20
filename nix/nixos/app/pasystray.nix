{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.pasystray ];
  systemd.user.services.pasystray = {
    description = "Run a one-shot command upon user login to launch pasystray";
    wantedBy = [ "default.target" ];
    script = "${pkgs.pasystray}/bin/pasystray";
    environment = {
      DISPLAY = ":0.0";
    };
  };
}
