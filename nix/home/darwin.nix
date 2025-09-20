{ pkgs, username, ... }:
{
  imports = [
    ./common.nix
  ];

  home = {
    homeDirectory = "/Users/${username}";
  };

  home.packages = with pkgs; [
    gnupg
  ];
}
