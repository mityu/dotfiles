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

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:wez/wezterm/main?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      username = "mityu";
      pcs = [ "laptop-hp-envy"  "desktop-endeavor" ];
      des = {
        xfce = {
          modules = [ ./nixos/de/xfce.nix ];
          platform = "x11";
        };
        awesome = {
          modules = [ ./nixos/de/awesome.nix ];
          platform = "x11";
        };
      };
    in
    {
      nixosConfigurations =
        let
          inherit (nixpkgs) lib;

          getModuleOfPC = pc: ./nixos/pc/${pc}/configuration.nix;

          # Make a derivation for the set of "pc" and "de(Desktop Environment)".
          buildConfig = pc: de:
            let
              inherit (nixpkgs.lib) mkIf;
              nixosSystem = import ./nixos/nixosSystem.nix { inherit inputs username; };
              modules = [ (getModuleOfPC pc) ] ++ de.modules;
            in
            nixosSystem {
              inherit modules;
              platform = de.platform;
            } // mkIf (de ? system) { system = de.system; };

          buildConfigsForPC = des: pc:
            let f = deName: de:
              let name = "${pc}-${deName}"; in
              lib.nameValuePair name (buildConfig pc de);
            in
            lib.mapAttrs' f des;
        in
        lib.mergeAttrsList (map (buildConfigsForPC des) pcs);

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
      list-des = builtins.attrNames des;
    };
}
