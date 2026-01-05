{ pkgs, ... }:
let
  softether-overlay =
    final: prev:
    let
      softether = prev.softether.overrideAttrs (oldAttrs: {
        postInstall = "";
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.gcc14 ];
      });
    in
    {
      inherit softether;
    };
  dataDir = "/var/lib/softether";
  package = pkgs.softether;
in
{
  nixpkgs.overlays = [ softether-overlay ];
  environment.systemPackages = [ pkgs.softether ];

  # services.softether = {
  #   inherit package dataDir;
  #   enable = false;
  #   vpnclient.enable = false;
  # };

  systemd.services.softether-init = {
    description = "SoftEther VPN services initial task";
    wantedBy = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
    script = ''
      for d in vpnserver vpnbridge vpnclient vpncmd; do
          if ! test -e ${dataDir}/$d; then
              ${pkgs.coreutils}/bin/mkdir -m777 -p ${dataDir}/$d
              install -m666 ${package}${dataDir}/$d/hamcore.se2 ${dataDir}/$d/hamcore.se2
          fi
      done
      rm -rf ${dataDir}/vpncmd/vpncmd
      cp ${package}${dataDir}/vpncmd/vpncmd ${dataDir}/vpncmd/vpncmd
      chmod 777 ${dataDir}/vpncmd/vpncmd
    '';
  };

  systemd.services.vpnclient = {
    description = "SoftEther VPN Client";
    after = [ "softether-init.service" ];
    requires = [ "softether-init.service" ];
    wantedBy = [ "network.target" ];
    serviceConfig = {
      Type = "forking";
      ExecStart = "${package}/bin/vpnclient start";
      ExecStop = "${package}/bin/vpnclient stop";
      # ExecStart = "${dataDir}/vpnclient/vpnclient start";
      # ExecStop = "${dataDir}/vpnclient/vpnclient stop";
    };
    preStart = ''
      chmod -R 666 ${dataDir}/vpnclient
      rm -rf ${dataDir}/vpnclient/vpnclient
      # ln -s ${package}${dataDir}/vpnclient/vpnclient ${dataDir}/vpnclient/vpnclient
      cp ${package}${dataDir}/vpnclient/vpnclient ${dataDir}/vpnclient/vpnclient
      chmod 777 ${dataDir}/vpnclient/vpnclient
    '';
    postStop = ''
      rm -rf ${dataDir}/vpnclient/vpnclient
    '';
  };
  boot.kernelModules = [ "tun" ];
}
