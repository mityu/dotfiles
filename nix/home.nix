{ inputs, pkgs, ... }:
let username = "mityu"; in
let
  vim-overlay = final: prev:
    let
      overlayed = inputs.vim-overlay.overlays.features {
        compiledby = "${username}-nix";
        python3 = true;
      } final prev;
    in
    {
      # Enable GUI and clipboards
      vim = overlayed.vim.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
          pkgs.gtk3
          pkgs.xorg.libXmu
          pkgs.xorg.libXpm
        ];
        configureFlags = (oldAttrs.configureFlags or [ ]) ++ [
          "--enable-gui"
        ];
      });
    };
in
{
  nixpkgs = {
    overlays = [
      vim-overlay
    ];
  };

  imports = [ inputs.nur.modules.homeManager.default ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "22.11";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    bat
    # binutils  # Conflict with clang-tools
    bashInteractive
    cargo
    cmake
    curl
    deno
    efm-langserver
    eza
    fish
    gauche
    gdb
    gh
    go
    jq
    libgcc
    llvmPackages_19.clang-tools
    llvmPackages_19.libcxxClang
    ninja
    ocaml
    opam
    ripgrep
    rofi
    skim
    vhs
    vim
    wezterm
    yq-go
  ];

  programs.wezterm = {
    package = inputs.wezterm.packages.${pkgs.system}.default;
  };

  programs.firefox = {
    enable = true;
    languagePacks = [ "ja" ];
    profiles.${username} = {
      id = 0;
      isDefault = true;
      settings = {
        "general.smoothScroll" = true;
        "tabs.groups.enabled" = true;
        "browser.toolbars.bookmarks.visibility" = "never";
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "history,bookmarks,syncedtabs,aichat";
        "sidebar.revamp" = true;
        "sidebar.position_start" = false;
        "general.useragent.locale" = "ja";
        "font.language.group" = "ja";
        "layout.css.devPixelsPerPx" = 1.25;
        # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      extensions = {
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          ublacklist
        ];
        settings = {
          "@ublacklist".settings = {
            subscriptions = [
              {
                name = "";
                url = "https://raw.githubusercontent.com/108EAA0A/ublacklist-programming-school/main/uBlacklist.txt";
                enabled = true;
              }
            ];
          };
        };
      };
    };
  };
}
