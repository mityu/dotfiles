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

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vim-overlay = {
      url = "github:kawarimidoll/vim-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:wez/wezterm/main?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-index-database,
      ...
    }:
    let
      username = "mityu";
      pc = [
        "laptop-hp-envy"
        "desktop-endeavor"
      ];
      des = {
        xfce = {
          modules = [ ./nixos/de/xfce.nix ];
          platform = "xfce";
        };
        awesome = {
          modules = [ ./nixos/de/awesome.nix ];
          platform = "x11";
        };
      };
      profiles = (import ./lib/mkCombination.nix { lib = nixpkgs.lib; }) {
        inherit pc;
        de = builtins.attrNames des;
      };
    in
    {
      nixosConfigurations =
        let
          inherit (nixpkgs) lib;

          getModuleOfPC = pc: ./nixos/pc/${pc}/configuration.nix;

          buildConfig =
            { pc, de }:
            let
              inherit (nixpkgs.lib) mkIf;
              nixosSystem = import ./nixos/nixosSystem.nix { inherit inputs username; };
              deConfig = des.${de};

              modules = [ (getModuleOfPC pc) ] ++ deConfig.modules;
              config = nixosSystem {
                inherit modules;
                system = mkIf (deConfig ? system) deConfig.system;
                platform = deConfig.platform;
              };
            in
            {
              "${pc}-${de}" = config;
            };
        in
        lib.mergeAttrsList (map buildConfig profiles);

      homeConfigurations =
        let
          getPlatformInfo = import ./lib/getPlatformInfo.nix;
          buildConfig =
            { pc, de }:
            let
              config = home-manager.lib.homeManagerConfiguration {
                pkgs = import nixpkgs {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
                extraSpecialArgs = {
                  inherit inputs;
                  inherit username;
                  hardware = pc;
                  platform = getPlatformInfo de;
                };
                modules = [
                  ./home/linux.nix
                  nix-index-database.homeModules.nix-index
                ];
              };
            in
            {
              "${pc}-${de}" = config;
            };
        in
        (nixpkgs.lib.mergeAttrsList (map buildConfig profiles))
        // {
          darwin = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
            extraSpecialArgs = {
              inherit inputs;
              inherit username;
              hardware = "mac";
              platform = getPlatformInfo "darwin";
            };
            modules = [
              ./home/darwin.nix
              nix-index-database.homeModules.nix-index
            ];
          };
        };
      list-des = builtins.attrNames des;
    };
}
