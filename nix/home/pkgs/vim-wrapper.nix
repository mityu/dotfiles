{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    literalExpression
    types
    ;
  cfg = config.programs.myvim;
in
{
  options.programs.myvim = {
    enable = mkEnableOption "";

    package = lib.mkPackageOption pkgs "vim" { default = "vim"; };

    extraPackages = mkOption {
      type = with types; listOf package;
      default = [ ];
      example = literalExpression "[ pkgs.shfmt ]";
      description = "Extra packages available to nvim.";
    };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      description = "Resulting customized neovim package.";
    };
  };

  config =
    let
      wrappedVim = pkgs.writeShellScriptBin "vim" ''
        PATH="${lib.makeBinPath cfg.extraPackages}:$PATH"
        export PATH
        exec ${lib.getExe cfg.package} "$@"
      '';
      resultingVim = if builtins.length cfg.extraPackages == 0 then cfg.package else wrappedVim;
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.finalPackage ];

      programs.myvim.finalPackage = resultingVim;
    };
}
