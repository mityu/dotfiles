{ pkgs, windowManager, username, ... }:
  if windowManager.X11 then
    {
      services.xremap = {
        userName = username;
        serviceMode = "system";
        withX11 = true;
        watch = true;
        yamlConfig = builtins.readFile ../../../xremap/config.yml;
      };

      systemd.user.services.set-xhost = {
        description = "Run a one-shot command upon user login";
        path = [ pkgs.xorg.xhost ];
        wantedBy = [ "default.target" ];
        script = "xhost +SI:localuser:root";
        environment.DISPLAY = ":0.0";
      };
    }
  else if windowManager.NiriWM then
    {
      services.xremap = {
        userName = username;
        serviceMode = "system";
        withNiri = true;
        watch = true;
        yamlConfig = builtins.readFile ../../../xremap/config.yml;
      };
    }
  else
    {
      services.xremap = {
        userName = username;
        serviceMode = "system";
        withWlroots = true;
        watch = true;
        yamlConfig = builtins.readFile ../../../xremap/config.yml;
      };
    }
