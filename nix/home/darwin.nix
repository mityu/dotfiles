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
    stateVersion = "26.05";
  };

  home.packages = with pkgs; [
    # cabextract
    darwin.trash
    gnupg
    git
    translate-shell
    ott
  ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };
}
