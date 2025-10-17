{ pkgs, config, ... }:
let
  inherit (config.feat) platform;
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    # enableGtk3 = true;
    fcitx5 = {
      waylandFrontend = with platform; !X11 && Wayland;
      addons = [ pkgs.fcitx5-mozc ];
      settings = {
        # This configuration will be written to "~/.config/fcitx5/config"
        globalOptions = {
          Hotkey = {
            EnumerateWithTriggerKeys = true;
            EnumerateForwardKeys = "";
            EnumerateBackwardKeys = "";
            EnumerateSkipFirst = false;
            ModifierOnlyKeyTimeout = 250;
          };
          "Hotkey/TriggerKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/EnumerateGroupForwardKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/EnumerateGroupBackwardKeys" = {
            "0" = "Shift+Super+space";
          };
          "Hotkey/AltTriggetKeys" = {
            "0" = "Shift_L";
          };
          "Hotkey/ActivateKeys" = {
            "0" = "Henkan";
          };
          "Hotkey/DeactivateKeys" = {
            "0" = "Muhenkan";
          };
          "Hotkey/PrevPage" = {
            "0" = "Up";
          };
          "Hotkey/NextPage" = {
            "0" = "Down";
          };
          "Hotkey/PrevCandidate" = {
            "0" = "Control+P";
            "1" = "Shift+Tab";
          };
          "Hotkey/NextCandidate" = {
            "0" = "Control+N";
            "1" = "Tab";
          };
          "Hotkey/TogglePreedit" = {
            "0" = "Control+Alt+P";
          };
          "Behavior" = {
            ActiveByDefault = false;
            resetStateWhenFocusIn = "No";
            ShareInputState = "No";
            ShowInputMethodInformation = true;
            showInputMethodInformationWhenFocusIn = false;
            CompactInputMethodInformation = true;
            ShowFirstInputMethodInformation = true;
            DefaultPageSize = 5;
            OverrideXkbOption = false;
            CustomXkbOption = "";
            EnabledAddons = "";
            DisabledAddons = "";
            PreloadInputMethod = true;
            AllowInputMethodForPassword = false;

            # Show preedit in application
            PreeditEnabledByDefault = true;

            # Show preedit text when typing password
            ShowPreeditForPassword = false;

            # Interval of saving user data in minutes
            AutoSavePeriod = 30;
          };
        };

        # This configuration will be written to "~/.config/fcitx5/profile"
        inputMethod = {
          GroupOrder = {
            "0" = "Default";
          };
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = "";
          };
        };
      };
    };
  };
}
