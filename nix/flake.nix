{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      nixpkgs-stable,
      home-manager,
      nix-darwin,
      nix-index-database,
      ...
    }:
    let
      username = "mityu";
      pc = [
        "laptop-hp-envy"
        "desktop-endeavor"
        "desktop-b760m-pro"
      ];
      des = {
        xfce = {
          modules = [ ./nixos/de/xfce.nix ];
        };
        awesome = {
          modules = [ ./nixos/de/awesome.nix ];
        };
      };
      profiles = nixpkgs.lib.cartesianProduct {
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
              inherit (inputs.nixpkgs.lib) nixosSystem;

              featModule = import ./module/feat.nix {
                hardware = pc;
                desktopEnvironment = de;
              };
              deConfig = des.${de};

              modules = [
                featModule
                (getModuleOfPC pc)
              ]
              ++ deConfig.modules;

              system = deConfig.system or "x86_64-linux";
            in
            {
              "${pc}-${de}" = nixosSystem {
                inherit modules system;
                specialArgs = inputs // {
                  inherit username;
                  pkgs-stable = import nixpkgs-stable {
                    inherit system;
                    config.allowUnfree = true;
                  };
                };
              };
            };
        in
        lib.mergeAttrsList (map buildConfig profiles);

      homeConfigurations =
        let
          buildConfig =
            { pc, de }:
            let
              featModule = import ./module/feat.nix {
                hardware = pc;
                desktopEnvironment = de;
              };
              config = home-manager.lib.homeManagerConfiguration {
                pkgs = import nixpkgs {
                  system = des.${de}.system or "x86_64-linux";
                  config.allowUnfree = true;
                };
                extraSpecialArgs = {
                  inherit inputs;
                  inherit username;
                };
                modules = [
                  featModule
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
            };
            modules = [
              (import ./module/feat.nix {
                hardware = "mac";
                desktopEnvironment = "darwin";
              })
              ./home/darwin.nix
              nix-index-database.homeModules.nix-index
            ];
          };
        };
      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit username;
        };
        modules = [ ./nix-darwin/default.nix ];
      };
      list-des = builtins.attrNames des;
    };
}
