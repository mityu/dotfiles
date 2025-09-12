{ pkgs, ... }:
  {
    environment.systemPackages = [ pkgs.networkmanagerapplet ];
    systemd.user.services.nm-applet = {
      Unit = {
        Description = "Run a one-shot command upon user login to launch nm-applet";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        Environment = [ "DISPLAY=:0.0" ];
      };
    };
  }
