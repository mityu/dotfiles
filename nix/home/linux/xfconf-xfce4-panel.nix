{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    mkIf
    types
    ;

  cfg = config.xfconf-xfce4-panel;

  mkOptionalOption =
    opt:
    mkOption {
      type = types.nullOr opt.type;
      default = null;
    };

  typePlugin = types.submodule {
    options = {
      name = mkOptionalOption {
        type = types.str;
      };
      package = mkOptionalOption {
        type = types.package;
      };
      attrs = mkOption {
        type = types.attrs;
        default = { };
      };
      configFile = mkOptionalOption {
        type = types.lines;
      };
    };
  };

  typePanel = types.submodule {
    options = {
      size = mkOptionalOption {
        type = types.oneOf [
          types.int
          types.float
        ];
      };
      icon-size = mkOptionalOption {
        type = types.oneOf [
          types.int
          types.float
        ];
      };
      autohide-behavior = mkOptionalOption {
        type = types.int;
      };
      position = mkOptionalOption {
        type = types.str;
      };
      position-locked = mkOptionalOption {
        type = types.bool;
      };
      length = mkOptionalOption {
        type = types.int;
      };
      plugins = mkOption {
        type = types.functionTo (types.listOf typePlugin);
        default = _: [ ];
        description = "Takes a pre-defined plugin list and should return a list of plugins for the panel.";
      };
    };
  };

  normalizePluginDefs =
    pluginDefs:
    let
      completeAttrs =
        name: value:
        lib.updateManyAttrsByPath [
          {
            path = [ "name" ];
            update = old: if old == null then name else old;
          }
        ] value;
    in
    builtins.mapAttrs completeAttrs pluginDefs;

  attrsToConfig =
    prefix: attrs:
    let
      attrsToNameValuePairList =
        prefix: attrs:
        let
          mapf =
            v:
            let
              key = "${prefix}/${v.name}";
            in
            if builtins.isAttrs v.value then
              attrsToNameValuePairList key v.value
            else
              [ (lib.nameValuePair key v.value) ];
        in
        builtins.concatMap mapf (lib.attrsToList attrs);
    in
    builtins.listToAttrs (attrsToNameValuePairList prefix attrs);

  buildOnePanelSettings =
    givenPlugins: acc: panel:
    let
      validatePlugins =
        plugins:
        let
          noNamePlugins = lib.pipe plugins [
            builtins.attrNames
            (builtins.filter (n: plugins.${n}.name == null))
          ];
        in
        if builtins.length noNamePlugins != 0 then
          throw "Internal error: the 'name' attributes of these plugins are null: ${toString noNamePlugins}"
        else
          plugins;
    in
    let
      panelConfigPrefix = "panels/panel-${toString acc.idx}";
      plugins = panel.plugins (validatePlugins givenPlugins); # List of plugins on this panel.
      ids = builtins.genList (x: x + acc.pluginCount + 1) (builtins.length plugins);
      foreachPlugins =
        fn:
        let
          zip = lib.zipLists ids plugins;
        in
        builtins.foldl' (acc: v: acc // (fn v.fst v.snd)) { } zip;

      pluginSettings =
        let
          pluginRegisterer = foreachPlugins (
            idx: plugin:
            let
              prefix = "plugins/plugin-${toString idx}";
            in
            { ${prefix} = plugin.name; } // attrsToConfig prefix plugin.attrs
          );
        in
        pluginRegisterer // { "${panelConfigPrefix}/plugin-ids" = ids; };

      otherSettings = attrsToConfig panelConfigPrefix (
        lib.filterAttrs (n: v: n != "plugins" && v != null) panel
      );

      configFiles = foreachPlugins (
        idx: plugin:
        if plugin.configFile == null then
          { }
        else
          let
            rcName = "${plugin.name}-${toString idx}.rc";
          in
          {
            "xfce4/panel/${rcName}" = {
              force = true;
              text = plugin.configFile;
            };
          }
      );
    in
    {
      idx = acc.idx + 1;
      pluginCount = acc.pluginCount + (builtins.length plugins);
      settings = acc.settings // pluginSettings // otherSettings;
      configFiles = acc.configFiles // configFiles;
    };

  buildSettings =
    { panels, plugins, ... }:
    let
      normalizedPlugins = normalizePluginDefs plugins;
      nul = {
        idx = 1;
        pluginCount = 0;
        settings = { };
        configFiles = { };
      };
    in
    lib.pipe panels [
      (builtins.foldl' (buildOnePanelSettings normalizedPlugins) nul)
      (lib.filterAttrs (
        n: v:
        builtins.elem n [
          "settings"
          "configFiles"
        ]
      ))
    ];
in
{
  options.xfconf-xfce4-panel = {
    dark-mode = mkOption {
      type = types.nullOr types.bool;
      default = null;
    };
    plugins = mkOption {
      type = types.attrsOf typePlugin;
      default = { };
    };
    panels = mkOption {
      type = types.listOf typePanel;
      default = [ ];
    };
    settings = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config =
    let
      settings = buildSettings cfg;
    in
    {
      xfconf.settings.xfce4-panel = {
        "panels" = builtins.genList (x: x + 1) (builtins.length cfg.panels);
        "panels/dark-mode" = mkIf (cfg.dark-mode != null) cfg.dark-mode;
      }
      // settings.settings
      // (cfg.settings);

      home.packages = lib.pipe cfg.plugins [
        builtins.attrValues
        (map (v: v.package))
        (builtins.filter (v: v != null))
      ];

      xdg.configFile = settings.configFiles;
    };
}
