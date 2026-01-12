{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.gtrash;
in
{
  options.programs.gtrash = {
    enable = lib.mkEnableOption "gtrash";
    package = lib.mkPackageOption pkgs "gtrash" { };

    auto-prune = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Prune trash can automatically";
          schedule = lib.mkOption {
            type = lib.types.str;
            description = ''
              Specify how often gtrash prunes trash cans.
              This will goes to "OnCalender" field of systemd-timer unit file.

              The format should be in what systemd-timer recognize.
              See `$ man systemd.time` for the details.
            '';
            default = "*-*-* 12:00:00";
            example = ''
              *-*-* *:00:00
            '';
          };
          persistent = lib.mkOption {
            type = lib.types.bool;
            description = ''
              Specify the "Persistent" field of systemd-timer.
              When activated, it triggers the service immediately if it missed
              the last start time, for example due to the system being powered
              off.
            '';
            default = false;
            example = lib.literalExpression "true";
          };
          parameters = lib.mkOption {
            type = lib.types.submodule {
              options = {
                day = lib.mkOption {
                  type = with lib.types; nullOr ints.unsigned;
                  description = "Remove all files deleted before X days";
                  default = null;
                  example = lib.literalExpression "30";
                };
                size = lib.mkOption {
                  type = with lib.types; nullOr str;
                  description = ''
                    The total remaining size of trash can.
                    "gtrash" removes files in order from the largest to the smaller
                    one so that the overall size of the trash can is less than the
                    specified size.

                    If both "day" and "size" are specified, the most recent X days
                    are excluded from the remaining size calculation.  This may be
                    useful when you do not want to delete large files that have been
                    recently deleted.
                  '';
                  default = null;
                  example = ''
                    "3GB", "5MB" or etc
                  '';
                };
                trash-dir = lib.mkOption {
                  type = with lib.types; nullOr path;
                  description = ''
                    A full path for a trash can to prune.
                    When this is null, all trash cans are pruned.
                  '';
                  default = null;
                  example = lib.literalExpression "\"$HOME/.local/share/Trash\"";
                };
              };
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.gtrash = lib.mkIf cfg.auto-prune.enable {
      Unit = {
        Description = "Prune trash cans";
      };
      Service = {
        ExecStart =
          let
            buildArgs =
              attrs:
              lib.strings.join " " (
                lib.cli.toCommandLine (optionName: {
                  option = "--${optionName}";
                  sep = " ";
                  explicitBool = true;
                }) attrs
              );
          in
          "${lib.getExe cfg.package} prune ${buildArgs cfg.auto-prune.parameters}";
      };
    };

    systemd.user.timers.gtrash = lib.mkIf cfg.auto-prune.enable {
      Unit = {
        Description = "Automatically prune trash cans";
      };
      Timer = {
        OnCalendar = cfg.auto-prune.schedule;
        Persistent = cfg.auto-prune.persistent;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
