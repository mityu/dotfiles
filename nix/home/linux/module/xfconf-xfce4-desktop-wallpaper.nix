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
        # Tip: Use `xfconf-query -c xfce4-desktop -p /backdrop -r -R` to remove entire configuration about backgrounds.
        xfconf-query = "${lib.getExe pkgs.xfconf}";
        xrandr = "${lib.getExe pkgs.xorg.xrandr}";
        jc = "${lib.getExe pkgs.jc}";
        jq = "${lib.getExe pkgs.jq}";
        jqQuery = builtins.concatStringsSep "|" [
          ".screens[]"
          "{ screen_number: .screen_number, device_name: .devices[] | select(.is_connected == true) | .device_name }"
          ''"screen\(.screen_number)/monitor\(.device_name)"''
        ];
        buildSetter = workspace: wallpaper: ''
          ${xfconf-query} -c xfce4-desktop -l \
            | grep '${workspace}/last-image' \
            | xargs -I{} ${xfconf-query} -c xfce4-desktop -p {} -s ${wallpaper}
          if [[ ${workspace} == workspace* ]]; then
            ${xrandr} | ${jc} --xrandr | ${jq} -r '${jqQuery}' \
              | xargs -I{} ${xfconf-query} --channel xfce4-desktop --create --property /backdrop/{}/${workspace}/last-image --set ${wallpaper} --type string
          fi
        '';
        scriptLines = [
          "set +e" # TODO: Better solution to avoid using `set +e`?
          (if cfg ? "*" then buildSetter "[^/]*" cfg."*" else "")
        ]
        ++ lib.mapAttrsToList (n: v: buildSetter n v) (lib.filterAttrs (n: _: n != "*") cfg);
        script = builtins.concatStringsSep "\n" scriptLines;
      in
      lib.hm.dag.entryAfter [ "xfconfSettings" ] (lib.mkIf (!isEmpty cfg) script);
  };
}
