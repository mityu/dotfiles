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
    gnupg
    (import ./pkgs/ott.nix {
      inherit (inputs) opam-nix;
      inherit (pkgs.stdenv.hostPlatform) system;
    })
  ];
}
