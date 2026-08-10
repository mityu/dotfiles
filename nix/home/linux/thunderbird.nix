{
  lib,
  config,
  username,
  ...
}:
{
  imports = [
    ./module/birdtray.nix
  ];

  programs.thunderbird = {
    enable = true;
    languagePacks = [ "ja" ];
    profiles.${username} = {
      isDefault = true;
      settings = {
        "general.smoothScroll" = true;
        "layout.css.devPixelsPerPx" = 1.25;
        "intl.date_time.pattern_override.date_short" = "yyyy/MM/dd";
        "font.cjk_pref_fallback_order" = "ja,zh-cn,zh-hk,zh-tw,ko";
        "intl.locale.requested" = "ja,en-US";
      };
    };
  };

  programs.birdtray = {
    enable = true;
    settings = {
      "advanced/forcedRereadInterval" = 0;
      "advanced/ignoreNetWMhints" = false;
      "advanced/ignoreUpdateVersion" = "";
      "advanced/notificationfontmaxsize" = 512;
      "advanced/notificationfontminsize" = 4;
      "advanced/onlyShowIconOnUnreadMessages" = false;
      "advanced/runProcessOnChange" = "";
      "advanced/tbcmdline" = [ (lib.getExe config.programs.thunderbird.package) ];
      "advanced/tbprocessname" = "thunderbird";
      "advanced/tbwindowmatch" = " Thunderbird";
      "advanced/unreadopacitylevel" = 0.75;
      "advanced/updateOnStartup" = false;
      "advanced/watchfiletimeout" = 150;
      "common/allowsuppressingunread" = false;
      # "common/blinkspeed" = 0;
      # "common/bordercolor" = "#ffffff";
      # "common/borderwidth" = 0;
      # "common/defaultcolor" = "#0000ff";
      "common/exitthunderbirdonquit" = true;
      "common/forceIgnoreUnreadEmailsOnMinimize" = false;
      "common/hideWhenStartedManually" = true;
      "common/hidewhenminimized" = true;
      "common/hidewhenrestarted" = true;
      "common/hidewhenstarted" = true;
      "common/ignoreShowUnreadCount" = false;
      "common/ignoreStartUnreadCount" = false;
      "common/launchthunderbird" = true;
      "common/launchthunderbirddelay" = 0;
      "common/monitorthunderbirdwindow" = true;
      "common/newemailEnabled" = false;
      # "common/notificationfont" = "Noto Sans,10,-1,0,50,0,0,0,0,0";
      # "common/notificationfontweight" = 50;
      "common/restartthunderbird" = true;
      # "common/showDialogIfNoAccountsConfigured" = false;
      "common/showhidethunderbird" = true;
      "common/showunreademailcount" = false;
      "common/startClosedThunderbird" = true;
    };
  };
}
