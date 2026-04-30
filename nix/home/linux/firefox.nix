{
  pkgs,
  lib,
  username,
  config,
  ...
}:
let
  inherit (config.feat) enableTexPackages;
in
{
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    languagePacks = [ "ja" ];
    profiles.${username} = {
      id = 0;
      isDefault = true;
      settings = {
        "general.smoothScroll" = true;
        "tabs.groups.enabled" = true;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.download.autohideButton" = false;
        "sidebar.verticalTabs" = true;
        "browser.smartwindow.sidebar.openByDefault" = false;
        "sidebar.main.tools" = "history,bookmarks,syncedtabs,aichat,treestyletab@piro.sakura.ne.jp";
        "sidebar.revamp" = true;
        "sidebar.position_start" = false;
        "general.useragent.locale" = "ja";
        "font.language.group" = "ja";
        "font.cjk_pref_fallback_order" = "ja,zh-cn,zh-hk,zh-tw,ko";
        "intl.locale.requested" = "ja,en-US";
        "browser.search.region" = "JP";
        "layout.css.devPixelsPerPx" = 1.25;
        # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            nav-bar = [
              "back-button"
              "forward-button"
              "urlbar-container"
              "vertical-spacer"
              "downloads-button"
              "developer-button"
              "firefox-view-button"
              "alltabs-button"
              "unified-extensions-button"
              "bookmarks-menu-button"
              "history-panelmenu"
              "preferences-button"
              "sidebar-button"
              "ublock0_raymondhill_net-browser-action"
              "treestyletab_piro_sakura_ne_jp-browser-action"
            ];
          };
        };
        "extensions.autoDisableScopes" = 0; # Automatically enable extensions.
      };
      userChrome = builtins.readFile ./firefox/userChrome.css;
      extensions = {
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          ublacklist
          control-panel-for-twitter
          tree-style-tab
          (lib.mkIf enableTexPackages zotero-connector)
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
          "treestyletab@piro.sakura.ne.jp" = {
            permissions = [
              # Basic permissions
              "activeTab"
              "contextualIdentities"
              "cookies"
              "menus"
              "menus.overrideContext"
              "notifications"
              "search"
              "sessions"
              "storage"
              "tabGroups"
              "tabs"
              "theme"

              # Advanced permissions
              "browsingData"
              "bookmarks"
            ];
            settings = {
              tabPreviewTooltip = true;
              sidebarPosition = 1;
              userStyleRules = builtins.readFile ./firefox/tree-style-tab-style.css;
            };
          };
        };
      };
      search = {
        force = true;
        default = "google";
        engines =
          let
            engine =
              {
                name ? null,
                icon,
                aliases,
                url,
                params,
                ...
              }:
              {
                inherit icon;
                definedAliases = map (v: "!${v}") (if builtins.isString aliases then [ aliases ] else aliases);
                urls = [
                  {
                    template = url;
                    inherit params;
                  }
                ];
              }
              // lib.optionalAttrs (builtins.isString name) { inherit name; };
            searchParam = key: [
              {
                name = key;
                value = "{searchTerms}";
              }
            ];
            commonSearchParam = searchParam "q";
          in
          {
            github = engine rec {
              base = "https://github.com";
              icon = "${base}/favicon.ico";
              url = "${base}/search";
              aliases = [
                "gh"
                "github"
              ];
              params = commonSearchParam;
            };

            google = engine rec {
              base = "htttps://google.com";
              icon = "${base}/favicon.ico";
              url = "${base}/search";
              aliases = "google";
              params = commonSearchParam;
            };

            nixpkgs-pkgs = engine {
              url = "https://search.nixos.org/packages";
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              aliases = [
                "nix"
                "nixpkg"
                "nixpkgs"
              ];
              params = lib.attrsToList {
                channel = "unstable";
                query = "{searchTerms}";
              };
            };

            nixpkgs-opts = engine {
              url = "https://search.nixos.org/options";
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              aliases = "nixopts";
              params = lib.attrsToList {
                channel = "unstable";
                query = "{searchTerms}";
              };
            };

            mynixos = engine rec {
              base = "https://mynixos.com";
              icon = "${base}/favicon.ico";
              url = "${base}/search";
              aliases = "mynixos";
              params = commonSearchParam;
            };

            home-manager-options = engine rec {
              base = "https://home-manager-options.extranix.com";
              icon = "${base}/images/favicon.ico";
              url = base;
              aliases = [
                "hm"
                "home-manager-options"
                "home"
              ];
              params = lib.attrsToList {
                release = "master";
                query = "{searchTerms}";
              };
            };

            noogle = engine rec {
              base = "https://noogle.dev";
              icon = "${base}/favicon.png";
              url = "${base}/q";
              aliases = "noogle";
              params = searchParam "term";
            };

            npm = engine {
              icon = "https://static-production.npmjs.com/b0f1a8318363185cc2ea6a40ac23eeb2.png";
              url = "https://www.npmjs.com/search";
              aliases = "npm";
              params = commonSearchParam;
            };

            jsr = engine rec {
              base = "https://jsr.io";
              icon = "${base}/favicon.ico";
              url = "${base}/packages";
              aliases = "jsr";
              params = searchParam "search";
            };

            rust-crates-io = engine rec {
              name = "crates.io";
              base = "https://crates.io";
              icon = "${base}/favicon.ico";
              url = "${base}/search";
              aliases = [
                "crate"
                "crates"
              ];
              params = commonSearchParam;
            };

            rust-docs-rs = engine rec {
              name = "docs.rs";
              base = "https://docs.rs";
              icon = "${base}/favicon.ico";
              url = "${base}/releases/search";
              aliases = [
                "docs.rs"
                "docs-rs"
              ];
              params = searchParam "query";
            };
          };
      };
    };
  };

}
