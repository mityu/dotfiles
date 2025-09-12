{ pkgs, ... }:
  {
    environment.systemPackages = [ pkgs.pasystray ];
    systemd.user.services.pasystray = {
      Unit = {
        Description = "Run a one-shot command upon user login to launch pasystray";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${pkgs.pasystray}/bin/pasystray";
        Environment = [ "DISPLAY=:0.0" ];
      };
    };
  }
