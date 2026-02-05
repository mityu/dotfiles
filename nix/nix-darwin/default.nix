{
  pkgs,
  username,
  ...
}:
{
  imports = [ ./module/compiler-infra.nix ];

  nix = {
    gc = {
      automatic = true;
      interval = {
        Hour = 9;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = "nix-command flakes";
    };
  };

  system = {
    stateVersion = 6; # Do not modify this unless your're certain to change this.
    primaryUser = username;
  };

  compiler-infra = {
    enable = false;
    accessibleGlobally = true;
    apple-sdk = pkgs.apple-sdk_15;
    libs = with pkgs; [
      libiconv
      ncurses
    ];
  };

  programs.fish = {
    enable = true;
    useBabelfish = true;

    # Call path_helper during fish initialization to set PATH to some external
    # applications such as mactex managed by Homebrew.
    loginShellInit = ''
      if path is -fx /usr/libexec/path_helper
        eval (/usr/libexec/path_helper -c)
      end
    '';
  };
}
