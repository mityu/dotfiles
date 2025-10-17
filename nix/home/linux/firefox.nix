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
        "sidebar.main.tools" = "history,bookmarks,syncedtabs,aichat";
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
            ];
          };
        };
        "extensions.autoDisableScopes" = 0; # Automatically enable extensions.
      };
      extensions = {
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          ublacklist
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
        };
      };
    };
  };

}
