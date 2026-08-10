{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.birdtray;
  baseconf = pkgs.writeText "birdtray-base-config.json" (builtins.toJSON cfg.settings);
  genconf = pkgs.writers.writePython3Bin "gen-birdtray-config" {
    libraries = [ ];
  } (builtins.readFile ./birdtray/genconf.py);
  launcher = pkgs.writeShellApplication {
    name = "launch-birdtray";
    runtimeInputs = [
      pkgs.jq
      genconf
      cfg.package
    ];
    runtimeEnv = {
      XDG_CONFIG_HOME = config.xdg.configHome;
    };
    text = ''
      gen-birdtray-config --base-config "${baseconf}"
      exec birdtray
    '';
  };
in
{
  options.programs.birdtray = {
    enable = lib.mkEnableOption "birdtray";
    package = lib.mkPackageOption pkgs "birdtray" { };
    settings = lib.mkOption {
      type = lib.types.attrs;
      description = ''
        This value will go into $XDG_CONFIG_HOME/birdtray-config.json.
      '';
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."autostart/Birdtray.desktop".text = lib.generators.toINI { } {
      "Desktop Entry" = {
        Name = "Birdtray";
        Comment = "Launch Birdtray";
        Exec = "${lib.getExe launcher}";
        Terminal = false;
        Type = "Application";
        Hidden = false;
      };
    };
  };
}
