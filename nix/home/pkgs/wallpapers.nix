{ pkgs, ... }:
let
  images = [
    {
      url = "http://cache.typemoon.com/images/i7b9bc9628d56fe8cc6cadcb76570b4bbmg";
      hash = "sha256-NtpuwyKNWP0gknCpQO/zc6b+YQFTjkDeGwRzwTz9Lfw=";
      name = "mahoyo-alice-house-table.jpeg";
    }
    {
      url = "http://cache.typemoon.com/images/ib4bf865d7c85d4ccdab28dda13fa1cdemg";
      hash = "sha256-oF8f/Hw4x+aJlC9TnwPsBfazNIoLkLmZWXfgcQCiJRc=";
      name = "mahoyo-misakicho.jpeg";
    }
    {
      url = "https://mahoyo-movie.com/assets/img/kv/poster_pc.jpg";
      hash = "sha256-9IBC76e19zuteN6J/rOP7nWJfdpBOeyCGTC+vkeYMtQ=";
      name = "mahoyo-movie-poster.jpg";
    }
    {
      # https://www.pixiv.net/artworks/69000196
      url = "https://i.pximg.net/img-original/img/2018/05/31/00/00/03/69000196_p0.png";
      curlOptsList = [
        "-H"
        "Referer:https://app-api.pixiv.net/"
      ];
      hash = "sha256-5J6LE3PaUX26veB34p/MK0+0EO3F2iJq1Zyo1B5qal4=";
      name = "fgo-mash.png";
    }
  ];
in
pkgs.callPackage (
  {
    lib,
    stdenvNoCC,
    fetchurl,
  }:
  let
    imagePkgs = map (v: {
      src = fetchurl (lib.filterAttrs (n: _: n != "name") v);
      dst = v.name;
    }) images;
    builderScript = [ "mkdir -p $out/" ] ++ (map (v: "cp ${v.src} $out/${v.dst}")) imagePkgs;
  in
  stdenvNoCC.mkDerivation {
    pname = "wallpapers";
    version = "none";

    srcs = map (v: v.src) imagePkgs;
    builder = pkgs.writeShellScript "builder.sh" (builtins.concatStringsSep "\n" builderScript);

    meta = with lib; {
      license = licenses.unfree;
      platforms = platforms.all;
    };
  }
) { }
