# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs, ... }:
let
  cica-font-pkg = { lib, stdenvNoCC, fetchzip }:
    stdenvNoCC.mkDerivation rec {
      pname = "cica";
      version = "5.0.3";

      src = fetchzip {
        url = "https://github.com/miiton/Cica/releases/download/v${version}/Cica_v${version}.zip";
        hash = "sha256-BtDnfWCfD9NE8tcWSmk8ciiInsspNPTPmAdGzpg62SM=";
        stripRoot = false;
      };

      installPhase = ''
        runHook preInstall
        install -Dm644 *.ttf -t $out/share/fonts/Cica
        runHook postInstall
      '';

      meta = with lib; {
        license = licenses.ofl;
        homepage = "https://github.com/miiton/Cica";
        platforms = platforms.all;
      };
    };
  awesome-deficient-pkg = { lua, stdenvNoCC, fetchFromGitHub }:
    stdenvNoCC.mkDerivation rec {
      pname = "awesome-deficient";
      version = "22ad2bea198f0c231afac0b7197d9b4eb6d80da3";

      src = fetchFromGitHub {
        owner = "deficient";
        repo = "deficient";
        rev = version;
        hash = "sha256-INZx053s/PIbRw3mLCobybVuuJENjhyxnsv3LDzi/AI=";
      };

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/lua/${lua.luaversion}/
        cp -r . $out/lib/lua/${lua.luaversion}/deficient/
        runHook postInstall
      '';

      meta = with lib; {
        license = licenses.unlicense;
        homepage = "https://github.com/deficient/deficient";
        platforms = platforms.all;
      };
    };
  awesome-awmtt-pkg = { lua, stdenvNoCC, fetchFromGitHub, luaModules, makeWrapper }:
    let mkSearchPathAdder = modules:
      let
        mkSearchPath = module: place: "${module}/${place}/lua/${lua.luaversion}";

        # The last space is necessary because awmtt concatenates arguments
        # given via "-a" without any white spaces.
        mkFlag = module: place: "--add-flags '-a \"--search ${mkSearchPath module place} \"'";
        flags = builtins.concatMap (v: builtins.map (mkFlag v) [ "lib" "share" ]) modules;
      in
      builtins.toString flags;
    in
    stdenvNoCC.mkDerivation rec {
      pname = "awesome-awmtt";
      version = "92ababc7616bff1a7ac0a8e75e0d20a37c1e551e";

      src = fetchFromGitHub {
        owner = "gmdfalk";
        repo = "awmtt";
        rev = version;
        hash = "sha256-3IpCuLIdN4t4FzFSHAlJ9FW9Y8UcWIqXG9DfiAwZoMY=";
      };

      nativeBuildInputs = [ makeWrapper ];

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp ./awmtt.sh $out/bin/.awmtt-wrapped
        chmod u+x $out/bin/.awmtt-wrapped
        makeWrapper "$out/bin/.awmtt-wrapped" "$out/bin/awmtt" \
          ${mkSearchPathAdder luaModules}
        runHook postInstall
      '';

      meta = with lib; {
        homepage = "https://github.com/gmdfalk/awmtt";
        license = licenses.mit;
        platforms = platforms.linux;
      };
    };
  cica-font = pkgs.callPackage cica-font-pkg { };
  awesome-deficient = pkgs.callPackage awesome-deficient-pkg { };
  awesome-luaModules = [
    pkgs.luaPackages.vicious
    pkgs.luaPackages.lgi
    awesome-deficient
  ];
  awesome-awmtt = pkgs.callPackage awesome-awmtt-pkg { luaModules = awesome-luaModules; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ] ++ (with inputs.nixos-hardware.nixosModules; [
      common-pc-ssd
    ]) ++ [
      inputs.xremap.nixosModules.default
    ];

  nixpkgs.overlays = [
    (self: super: { awesome = super.awesome.override { gtk3Support = true; }; })
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  # i18n.inputMethod = {
  #   enabled = true;
  #   type = "fcitx5";
  #   fcitx5.addons = [pkgs.fcitx5-mozc];
  # };

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.noto
      hackgen-nf-font
      cica-font
      ipaexfont
    ];
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

  # Enable the X11 windowing system.
  programs.dconf.enable = true;
  services.xserver = {
    enable = true;

    displayManager = {
      lightdm.enable = true;
    };

    windowManager = {
      i3.enable = false;
      awesome.enable = true;

      awesome = {
        luaModules = awesome-luaModules;
      };
    };
  };


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

  services.xremap = {
    userName = "mityu";
    serviceMode = "system";
    withX11 = true;
    watch = true;
    yamlConfig = builtins.readFile ../xremap/config.yml;
  };

  # systemd.user.services.xremap = {
  #   description = "Startup xremap";
  #   path = [ inputs.xremap.xremap-x11 ];
  #   wantedBy = [ "default.target" ];
  #   script = [ "xremap --watch" ];
  # };

  systemd.user.services.set-xhost = {
    description = "Run a one-shot command upon user login";
    path = [ pkgs.xorg.xhost ];
    wantedBy = [ "default.target" ];
    script = "xhost +SI:localuser:root";
    environment.DISPLAY = ":0.0";
  };

  # systemd.user.services.set-fcitx5 = {
  #   description = "Run a one-shot command upon user login";
  #   path = [ pkgs.fcitx5 ];
  #   wantedBy = [ "default.target" ];
  #   script = "fcitx5";
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.fish.enable = true;
  users.users.mityu = {
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
    awesome
    awesome-awmtt
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

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

