{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vim-overlay = {
      url = "github:kawarimidoll/vim-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:wez/wezterm/main?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      username = "mityu";
      computers = {
        laptop-hp-envy = {
          system = "x86_64-linux";
          modules = [
            ./nixos/pc/laptop-hp-envy/configuration.nix
          ];
        };
      };
      des = {
        awesome = {
          module = ./nixos/de/awesome.nix;
          X11 = true;
          Wayland = false;
        };
      };
    in
    let
      lib = inputs.nixpkgs.lib;
      attrToItems = attrs: builtins.attrValues (lib.mapAttrs (k: v: lib.nameValuePair k v) attrs);
      pcList = attrToItems computers;
      deList = attrToItems des;

      buildNixosConfig =
        { username, lib }:
        let
          buildOneConfig =
            pc: wm:
            let
              key = pc.name + "-" + wm.name;
              param = pc.value // {
                specialArgs = {
                  inherit username;
                  inherit inputs;
                  windowManager = wm.value;
                };
              };
            in
            lib.nameValuePair key (lib.nixosSystem param);
        in
        let
          configList = map (pc: map (wm: buildOneConfig pc wm) deList) pcList;
        in
        lib.listToAttrs (lib.flatten configList);
    in
    {
      nixosConfigurations = buildNixosConfig {
        inherit username;
        lib = inputs.nixpkgs.lib;
      };
      homeConfigurations = {
        myHome = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs;
            inherit username;
          };
          modules = [ ./home/linux.nix ];
        };
      };
    };
}
