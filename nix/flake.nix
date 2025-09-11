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

  outputs = inputs:
    let
      username = "mityu";
      # buildNixosConfigurations =
      #   {
      #     nixosSystem,
      #     configSet,
      #     lib,
      #     username,
      #   }:
      #   let
      #     buildOneConfig = name: params:
      #       let drv = nixosSystem {
      #         system = "x86_64-linux";
      #         modules = [
      #           ./configuration.nix
      #         ];
      #         specialArgs = {
      #           inherit inputs;
      #           inherit username;
      #           windowManager = params;
      #         };
      #       };
      #       in
      #       nameValuePair name drv;
      #   in
      #   lib.attrsets.mapAttrs' buildOneConfig configSet;
      # osConfigSet = {
      #   awesome = {
      #     module = ./nixos/awesome-wm.nix;
      #     X11 = true;
      #     Wayland = false;
      #   };
      # };
    in
    {
      # nixosConfigurations = buildNixosConfigurations {
      #   nixosSystem = inputs.nixpkgs.lib.nixosSystem;
      #   lib = inputs.pkgs.lib;
      #   inherit username;
      # };
      nixosConfigurations = {
        laptop-hp-envy-awesomewm = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nixos/pc/laptop-hp-envy/configuration.nix
          ];
          specialArgs = {
            inherit inputs;
            inherit username;
            windowManager = {
              module = ./nixos/wm/awesome.nix;
              X11 = true;
              Wayland = false;
            };
          };
        };
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
