{
  pkgs,
  username,
  inputs,
  ...
}:
{
  imports = [
    ./common.nix
  ];

  home = {
    homeDirectory = "/Users/${username}";
  };

  home.packages = with pkgs; [
    # cabextract
    darwin.trash
    gnupg
    git
    translate-shell
    (import ./pkgs/ott.nix {
      inherit (inputs) opam-nix;
      inherit (pkgs.stdenv.hostPlatform) system;
    })
  ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };
}
