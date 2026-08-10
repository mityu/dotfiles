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
    # text = ''
    #   if [[ ! -d "$HOME/.thunderbird" ]]; then
    #     cat "${baseconf}" > "$CONFIG_FILE"
    #     exit 0
    #   fi
    #
    #   if [[ ! -d "$XDG_CONFIG_HOME" ]]; then
    #     mkdir -p "$XDG_CONFIG_HOME"
    #   fi
    #   printf '%s\n' ~/.thunderbird/*/*Mail/*/INBOX.msf | \
    #     jq -Rn '{accounts: [inputs] | map(select(. != "")) | map({path: .})}' | \
    #     jq -s 'add' - "${baseconf}" > "$CONFIG_FILE"
    # '';
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

    systemd.user.services = {
      birdtray = {
        Unit = {
          Description = "Launch Birdtray on login into graphical session";
        };
        Service = {
          # ExecStart = lib.getExe cfg.package;
          ExecStart = lib.getExe launcher;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      # birdtray-autoconfig = {
      #   Unit = {
      #     Description = "Auto-configure Birdtray accounts from Thunderbird profiles";
      #     After = [ "birdtray.service" ];
      #   };
      #   Service = {
      #     Type = "oneshot";
      #     ExecStart = "${lib.getExe genconf}";
      #   };
      #   Install = {
      #     WantedBy = [ "graphical-session.target" ];
      #   };
      # };
    };
  };
}
