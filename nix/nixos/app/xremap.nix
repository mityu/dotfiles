{ pkgs, xremap, platform, username, ... }:
  if platform.X11 then
    {
      imports = [ xremap.nixosModules.default ];
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
  else if platform.NiriWM then
    {
      imports = [ xremap.nixosModules.default ];
      services.xremap = {
        userName = username;
        serviceMode = "user";
        withNiri = true;
        watch = true;
        yamlConfig = builtins.readFile ../../../xremap/config.yml;
      };
    }
  else
    {
      imports = [ xremap.nixosModules.default ];
      services.xremap = {
        userName = username;
        serviceMode = "user";
        withWlroots = true;
        watch = true;
        yamlConfig = builtins.readFile ../../../xremap/config.yml;
      };
    }
