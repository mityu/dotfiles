{ pkgs, lib, ... }:
pkgs.callPackage (
  { stdenvNoCC, fetchurl }:
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "wallpapers";
    version = "none";

    src = fetchurl {
      url = "https://drive.usercontent.google.com/download?id=15nxGfudC9g3A1lWrKZgkSwHujge1fyXd&confirm=yes";
      hash = "sha256-25dXH39xFzEcXJj4pSmyCn+KADB0mrabArQRDqgUCzg=";
      name = "assets.tar.gz.gpg";
    };

    nativeBuildInputs = with pkgs; [
      gnupg
      gnutar
    ];

    builder = pkgs.writeShellScript "builder.sh" ''
      mkdir -p $out
      export GNUPGHOME="$(mktemp -d)"
      echo -n 'd2FrdXdha3V3YWxscGFwZXJzZXQK' | base64 --decode | \
        gpg --no-options --batch --passphrase-fd 0 --output assets.tar.gz "$src"
      tar xvf assets.tar.gz --directory $out
    '';

    meta = with lib; {
      license = licenses.unfree;
      platforms = platforms.all;
    };
  })
) { }
