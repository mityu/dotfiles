{ pkgs, ... }:
  let pkg = { lib, stdenvNoCC, fetchzip }:
    stdenvNoCC.mkDerivation rec {
      pname = "cica";
      version = "5.0.3";

      src = fetchzip {
        url = "https://github.com/miiton/Cica/releases/download/v${version}/Cica_v${version}.zip";
        hash = "sha256-BtDnfWCfD9NE8tcWSmk8ciiInsspNPTPmAdGzpg62SM=";
        stripRoot = false;
      };

      installPhase = ''
        runHook preInstall
        install -Dm644 *.ttf -t $out/share/fonts/Cica
        runHook postInstall
      '';

      meta = with lib; {
        license = licenses.ofl;
        homepage = "https://github.com/miiton/Cica";
        platforms = platforms.all;
      };
    };
  in
  pkgs.callPackage pkg { }
