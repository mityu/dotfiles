# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  nixos-hardware,
  pkgs,
  pkgs-stable,
  lib,
  username,
  config,
  ...
}:
let
  sshPorts = [ 31725 ];
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-pc-ssd
    ../common.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    # package = config.boot.kernelPackages.nvidiaPackages.production;
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
  };

  networking.hostName = "rigel";

  services.printing.enable = true;
  services.printing.drivers = [
    (pkgs.callPackage (import ../../app/fujixerox-driver.nix) { })
  ];

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy.AutoEnable = true;
    };
  };
  services.blueman.enable = true;

  services.xrdp = {
    enable = true;
    defaultWindowManager = lib.mkIf (config.feat.platform.Xfce) "xfce4-session";
    audio.enable = true;
    openFirewall = true;
    # extraConfDirCommands =
    #   let
    #     additional = pkgs.writeText "xrdp-vnc" ''
    #       [xrdp1]
    #       name=sesman-vnc
    #       lib=libvnc.so
    #       username=ask
    #       password=ask
    #       ip=127.0.0.1
    #       port=5900
    #       # port=-1
    #     '';
    #   in
    #   ''
    #     cat ${additional} >> $out/xrdp.ini
    #   '';
  };

  services.openssh = {
    enable = true;
    ports = sshPorts;
    openFirewall = true;
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [ username ];
      UseDns = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };
  networking.firewall.allowedTCPPorts = sshPorts;

  # KVM
  # programs.virt-manager.enable = true;
  # users.groups.libvirtd.members = [ username ];
  # virtualisation = {
  #   libvirtd = {
  #     enable = true;
  #     qemu.swtpm.enable = true;
  #   };
  #   spiceUSBRedirection.enable = true;
  # };

  services.open-webui = {
    enable = true;
    package = pkgs-stable.open-webui;
    port = 11435;
    environment = {
      OLLAMA_API_BASE_URL = "http://llm:11434";
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      WEBUI_AUTH = "False";
    };
  };
  environment.variables = {
    OLLAMA_HOST = "llm:11434";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
