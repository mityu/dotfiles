{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.xfconf-xfce4-desktop-wallpaper;
  isEmpty = attrs: builtins.length (builtins.attrNames attrs) == 0;
in
{
  options.xfconf-xfce4-desktop-wallpaper = mkOption {
    type = types.attrsOf (
      types.oneOf [
        types.path
        types.str
      ]
    );
    default = { };
  };

  config = {
    # We don't need to check if DBus is active or not here because DBus must be
    # activated at the xonfSettings activation step.
    home.activation.xfconfSettingsPost =
      let
        xfconf-query = "${lib.getExe pkgs.xfce.xfconf}";
        buildSetter = workspace: wallpaper: ''
          ${xfconf-query} -c xfce4-desktop -l \
            | grep '${workspace}/last-image' \
            | xargs -I{} ${xfconf-query} -c xfce4-desktop -p {} -s ${wallpaper}
        '';
        scriptLines = [
          (if cfg ? "*" then buildSetter "[^/]*" cfg."*" else "")
        ]
        ++ lib.mapAttrsToList (n: v: buildSetter n v) (lib.filterAttrs (n: _: n != "*") cfg);
        script = builtins.concatStringsSep "\n" scriptLines;
      in
      lib.hm.dag.entryAfter [ "xfconfSettings" ] (lib.mkIf (!isEmpty cfg) script);
  };
}
