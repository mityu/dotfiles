{ inputs, username }:
let
  getPlatformInfo = import ../lib/getPlatformInfo.nix;

  moduleBuildParam =
    { lib, config, ... }:
    let
      inherit (lib) types;
      cfg = config.mynixos;
    in
    {
      # Use "mynixos" namespace so that lib.evalModules doesn't recursively
      # evaluate modules listed in given "modules" attribute.
      options.mynixos = {
        platform = lib.mkOption {
          type = types.enum [
            "x11"
            "wayland"
            "niri"
            "xfce"
          ];
        };
        modules = lib.mkOption {
          type = types.listOf (
            types.oneOf [
              types.path
              types.attrs
            ]
          );
        };
        system = lib.mkOption {
          type = types.str;
          apply = lib.systems.elaborate;
          default = "x86_64-linux";
        };
        specialArgs = lib.mkOption {
          type = types.attrs;
          visible = false;
        };
      };

      config.mynixos = {
        specialArgs = inputs // {
          inherit username;
          platform = getPlatformInfo cfg.platform;
        };
      };
    };

  nixosSystem =
    inputs: attrs:
    let
      inherit (inputs.nixpkgs) lib;
      modules = [
        moduleBuildParam
        { mynixos = attrs; }
      ];
      result = lib.evalModules { inherit modules; };
      param =
        let
          reqKeys = [
            "modules"
            "system"
            "specialArgs"
          ];
          predicate = n: _: builtins.elem n reqKeys;
        in
        lib.filterAttrs predicate result.config.mynixos;
    in
    lib.nixosSystem param;
in
nixosSystem inputs
