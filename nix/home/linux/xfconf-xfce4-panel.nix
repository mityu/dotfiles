{ lib, config, ... }:
  let
    inherit (lib) mkOption mkEnableOption mkIf types;

    cfg = config.xfconf-xfce4-panel;

    mkOptionalOption = opt: mkOption {
      type = types.nullOr opt.type;
      default = null;
    };

    typePlugin = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
        };
        attrs = mkOption {
          type = types.attrs;
          default = { };
        };
      };
    };

    # Same as "typePlugin", but the "name" attribute can be omitted.  This is
    # for the type of plugin definitions by users.
    typePluginDef = types.submodule {
      options = {
        name = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        attrs = mkOption {
          type = types.attrs;
          default = { };
        };
      };
    };

    typePanel = types.submodule {
      options = {
        size = mkOptionalOption {
          type = types.oneOf [ types.int types.float ];
        };
        icon-size = mkOptionalOption {
          type = types.oneOf [ types.int types.float ];
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

    normalizePluginDefs = pluginDefs:
      let
        completeAttrs = name: value: {
          name = if value.name != null then value.name else name;
          attrs = value.attrs;
        };
      in
      builtins.mapAttrs completeAttrs pluginDefs;

    attrsToConfig = prefix: lib.mapAttrs' (name: value: lib.nameValuePair "${prefix}/${name}" value);

    buildOnePanelSettings = givenPlugins: acc: panel:
      let
        panelConfigPrefix = "panels/panel-${toString acc.idx}";
        plugins = panel.plugins givenPlugins;

        pluginSettings =
          let
            ids = builtins.genList (x: x + acc.pluginCount + 1) (builtins.length plugins);
            foreachPlugins = fn:
              let zip = lib.zipLists ids plugins; in
              builtins.foldl' (acc: v: acc // (fn v.fst v.snd)) {} zip;
            pluginRegisterer = foreachPlugins (idx: plugin:
              let prefix = "plugins/plugin-${toString idx}"; in
              { ${prefix} = plugin.name; } //
              attrsToConfig prefix plugin.attrs
            );
          in
          pluginRegisterer // { "${panelConfigPrefix}/plugin-ids" = ids; };

        otherSettings = attrsToConfig panelConfigPrefix (lib.filterAttrs (n: v: n != "plugins" && v != null) panel);
      in
      {
        idx = acc.idx + 1;
        pluginCount = acc.pluginCount + (builtins.length plugins);
        settings = acc.settings // pluginSettings // otherSettings;
      };

    buildSettings = { panels, plugins, ... }:
      let
        normalizedPlugins = normalizePluginDefs plugins;
        nul = { idx = 1; pluginCount = 0; settings = {}; };
      in
      (builtins.foldl' (buildOnePanelSettings normalizedPlugins) nul panels).settings;
  in
  {
    options.xfconf-xfce4-panel = {
      dark-mode = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      plugins = mkOption {
        type = types.attrsOf typePluginDef;
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

    config = {
      xfconf.settings.xfce4-panel = {
        "panels" = builtins.genList (x: x + 1) (builtins.length cfg.panels);
        "panels/dark-mode" = mkIf (cfg.dark-mode != null) cfg.dark-mode;
      } // (buildSettings cfg) // (cfg.settings);
    };
  }
