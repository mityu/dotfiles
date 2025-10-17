{
  lib,
  config,
  pkgs,
  ...
}@allInputs:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;

  cfg = config.ollama-copilot;

  args = lib.pipe cfg [
    (lib.filterAttrs (
      n: _:
      !builtins.elem n [
        "enable"
        "package"
      ]
    ))
    (lib.filterAttrs (_: v: v != null))
    (lib.mapAttrsToList (
      n: v:
      let
        argvalue = if lib.strings.hasInfix "port" n then ":${toString v}" else toString v;
      in
      "-${n} ${argvalue}"
    ))
    (builtins.concatStringsSep " ")
  ];
in
{
  options.ollama-copilot = {
    enable = mkEnableOption "Enable ollama-copilot systemd service";

    package = mkOption {
      type = types.package;
      default = (import ../pkgs/ollama-copilot.nix allInputs);
      description = "The ollama-copilot package to use.";
    };

    model = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "LLM model to use";
    };

    num-predict = mkOption {
      type = types.nullOr types.number;
      default = null;
      description = "Number of predictions to return";
    };

    port = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = "Port to listen on";
    };

    port-ssl = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = "Port to listen on";
    };

    proxy-port = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = "Proxy port to listen on";
    };

    proxy-port-ssl = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = "Proxy port to listen on";
    };

    template = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Fill-in-middle template to apply in prompt";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.ollama-copilot = {
      Unit = {
        Description = "Start ollama-copilot server";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/ollama-copilot ${args}";
      };
    };
  };
}
