{ pkgs, lib, ... }:
{
  environment.systemPackages = [ pkgs.networkmanagerapplet ];
  systemd.user.services.nm-applet = {
    description = "Run a one-shot command upon user login to launch nm-applet";
    wantedBy = [ "default.target" ];
    script = lib.getExe pkgs.networkmanagerapplet;
    environment = {
      DISPLAY = ":0.0";
    };
  };
}
