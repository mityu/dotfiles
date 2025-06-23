{ pkgs, ... }:
{
    virtualisation.virtualbox.host.enable = true;
    boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];
}
