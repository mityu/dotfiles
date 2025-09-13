{ pkgs, username, windowManager, ... }:
{
  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    # enableGtk3 = true;
    fcitx5 = {
      waylandFrontend = with windowManager; !X11 && Wayland;
      addons = [ pkgs.fcitx5-mozc ];
      settings.globalOptions = {
        "Hotkey/TriggerKeys" = {};
        "Hotkey/ActivateKeys" = {
          "0" = "Henkan";
        };
        "Hotkey/DeactivateKeys" = {
          "0" = "Muhenkan";
        };
        "Hotkey/PrevCandidate" = {
          "0" = "Control+P";
          "1" = "Shift+Tab";
        };
        "Hotkey/NextCandidate" = {
          "0" = "Control+N";
          "1" = "Tab";
        };
      };
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.noto
      hackgen-nf-font
      ipaexfont
    ] ++ [ (import ../../localpkgs/cica-font.nix pkgs) ];
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif CJK JP" "Noto Color Emoji" ];
        sansSerif = [ "Noto Sans CJK JP" "Noto Color Emoji" ];
        monospace = [ "Noto Sans Mono CJK JP" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };


  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tappingDragLock = false;
      additionalOptions = ''
        Option "TappingDrag" "false"
        Option "ScrollPixelDistance" "50"
      '';
    };
  };

  services.xremap = pkgs.lib.mkIf windowManager.X11 {
    userName = username;
    serviceMode = "system";
    withX11 = true;
    watch = true;
    yamlConfig = builtins.readFile ../../../xremap/config.yml;
  };

  systemd.user.services.set-xhost = pkgs.lib.mkIf windowManager.X11 {
    description = "Run a one-shot command upon user login";
    path = [ pkgs.xorg.xhost ];
    wantedBy = [ "default.target" ];
    script = "xhost +SI:localuser:root";
    environment.DISPLAY = ":0.0";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.fish.enable = true;
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "pass123";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    wget
    libinput
  ];

  environment.shellAliases = {
    # Disable all of the bulitin shell aliases.
    l = null;
    ll = null;
    ls = null;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.bash.enableLsColors = false;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;

}
