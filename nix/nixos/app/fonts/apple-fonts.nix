{ pkgs, lib, ... }:
let
  genPkgDef =
    {
      pname,
      url,
      hash,
    }:
    {
      lib,
      stdenvNoCC,
      fetchurl,
    }:
    stdenvNoCC.mkDerivation {
      inherit pname;
      version = "none";

      src = fetchurl {
        inherit url hash;
      };

      nativeBuildInputs = with pkgs; [
        p7zip
        fd
      ];

      sourceRoot = "./";

      unpackCmd = ''
        runHook preUnpack
        7z x $curSrc
        find . -type f -name '*.pkg' -exec mv {} ./ \;
        7z x *.pkg
        7z x 'Payload~'
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        # fontname=$(ls | grep '.pkg$' | sed -E 's/\.pkg$//')
        # installdir="$out/share/fonts/opentype/$fontname"
        installdir="$out/share/fonts/opentype/${pname}"
        install -Dm644 Library/Fonts/*.otf -t "$installdir"
        runHook postInstall
      '';

      meta = with lib; {
        license = licenses.unfree;
        homepage = "https://developer.apple.com/fonts/";
        platforms = platforms.all;
      };
    };
  srcs = [
    {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      hash = "sha256-W0sZkipBtrduInk0oocbFAXX1qy0Z+yk2xUyFfDWx4s=";
    }
    {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
      hash = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
    }
    {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
      hash = "sha256-RWeq4GFt01r8NLrWvvVH5y/R5lhFMFozlzBkUY0dU0g=";
    }
    {
      url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
      hash = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ=";
    }
  ];
in
lib.pipe srcs [
  (map (v: v // { pname = lib.removeSuffix ".dmg" (baseNameOf v.url); }))
  (map (v: {
    name = lib.toLower (v.pname);
    value = pkgs.callPackage (genPkgDef v) { };
  }))
  builtins.listToAttrs
]
