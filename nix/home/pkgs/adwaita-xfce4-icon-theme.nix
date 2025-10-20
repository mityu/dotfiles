{ pkgs, ... }:
let
  adwaita-xfce4-icon-theme =
    { fetchFromGitHub, stdenvNoCC }:
    stdenvNoCC.mkDerivation rec {
      name = "adwaita-xfce4-icon-theme";
      version = "b33d65a2cbb0857e1cc8b3ec87458e3e9b56c4dd";

      src = fetchFromGitHub {
        owner = "shimmerproject";
        repo = "adwaita-xfce-icon-theme";
        rev = version;
        hash = "sha256-/DKs83Sh9IIBHWNHTdAo3NPYjT9CQcJKJgRqEV3s/58=";
      };

      installPhase = ''
        runHook preInstall
        mkdir -p $out

        # Install icons patch for xfce4
        make install

        # Install original icons.
        pushd ${pkgs.adwaita-icon-theme}
        ${pkgs.lib.getExe pkgs.fd} . --type f \
            --exec install -Dm666 "{}" "$out/{}" \;
        popd

        pushd $out/share/icons
        ${pkgs.lib.getExe pkgs.fd} . --maxdepth 1 --type d \
            --exec ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t "{}" \;
        popd

        runHook postInstall
      '';
    };
in
{
  nixpkgs.overlays = [
    (_: _: { adwaita-xfce4-icon-theme = pkgs.callPackage adwaita-xfce4-icon-theme { }; })
  ];
}
