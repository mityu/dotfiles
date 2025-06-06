{ pkgs, ... }:
  let
    deps = import ./awesome { inherit pkgs; };
    luaModules = [
      pkgs.luaPackages.vicious
      pkgs.luaPackages.lgi
      deps.deficient
    ];
    awmtt = deps.awmtt luaModules;
  in
  {
    nixpkgs.overlays = [
      (self: super: { awesome = super.awesome.override { gtk3Support = true; }; })
    ];

    environment.systemPackages = [ pkgs.awesome awmtt ];
    programs.dconf.enable = true;
    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      windowManager.awesome = {
        enable = true;
        inherit luaModules;
      };
    };
  }
