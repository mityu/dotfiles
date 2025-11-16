{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.libinput-gestures;
in
{
  options.services.libinput-gestures = {
    enable = lib.mkEnableOption "libinput-gestures";
    package = lib.mkPackageOption pkgs "libinput-gestures" { };

    device = lib.mkOption {
      type = lib.types.str;
      description = ''
        Which devices to enable libinput-gestures for.

        This can either be the explicit device name (see output of `libinput list-devices`,
        a path into /dev/input (preferably /dev/input/by-path/ or /dev/input/by-id/), or
        the catchall value 'all'.
      '';
      default = "all";
      example = "DLL0665:01 06CB:76AD Touchpad";
    };

    swipe_threshold = lib.mkOption {
      type = lib.types.ints.unsigned;
      description = "Minimum travel distance for swipe gestures to be actioned";
      default = 0;
      example = 100;
    };

    timeout = lib.mkOption {
      type = lib.types.numbers.nonnegative;
      description = "Timeout for gesture commands";
      default = 1.5;
      example = 2;
    };

    gestures = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          freeformType =
            let
              multiFingerType = lib.types.submodule {
                options =
                  let
                    mkOption = fingerCount: {
                      name = fingerCount;
                      value = lib.mkOption {
                        type = with lib.types; nullOr str;
                        description = "Command to run when gesture is activated with ${fingerCount} fingers.";
                        default = null;
                        example = lib.literalExpression "\"\${lib.getExe pkgs.xdotool} key control+Tab\"";
                      };
                    };
                  in
                  lib.listToAttrs [
                    (
                      (mkOption "default")
                      // {
                        description = ''
                          Command to run when gesture is activated with any amount of fingers.

                          The other options take precedence over this command.
                        '';
                      }
                    )
                    (mkOption "1")
                    (mkOption "2")
                    (mkOption "3")
                    (mkOption "4")
                    (mkOption "5")
                  ];
              };
              # TODO: coercing doesn't work well now.
              # https://github.com/NixOS/nixpkgs/issues/352253
              # coerce = command: lib.traceValSeq { default = command; };
            in
            # with lib.types;
            # coercedTo str coerce multiFingerType;
            multiFingerType;
        }
      );
      default = { };
      example = lib.literalExpression ''
        {
          "swipe right" = "''${lib.getExe pkgs.xdotool} key control+Tab";
          "swipe left" = "''${lib.getExe pkgs.xdotool} key control+shift+Tab";
          "swipe up" = {
            default = "''${lib.getExe pkgs.xdotool} key control+shift+Tab";
            "1" = "''${lib.getExe pkgs.xdotool} key control+shift+Tab";
            "2" = "''${lib.getExe pkgs.xdotool} key control+shift+Tab";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.libinput-gestures = {
      Unit = {
        Description = "Launch libinput-gestures";
        Documentation = "https://github.com/bulletmark/libinput-gestures";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionGroup = [ "input" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.libinput-gestures}";

        # See also `man systemd.special`
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    xdg.configFile."libinput-gestures.conf".text =
      let
        gestureConfig = lib.pipe cfg.gestures [
          (lib.mapAttrs (k: lib.filterAttrs (_k: v: v != null)))
          (lib.mapAttrsToList (
            k: v:
            lib.mapAttrsToList (
              k': v': if k' == "default" then "gesture ${k} ${v'}" else "gesture ${k} ${k'} ${v'}"
            ) v
          ))
          (lib.concatLists)
          (lib.concatStringsSep "\n")
        ];
      in
      ''
        ${gestureConfig}
        device ${cfg.device}
        swipe_threshold ${toString cfg.swipe_threshold}
        timeout ${toString cfg.timeout}
      '';
  };
}
