{ pkgs, lib, ... }:
let
  images =
    { fromNet, fromLocal }:
    [
      (fromNet {
        url = "http://cache.typemoon.com/images/i7b9bc9628d56fe8cc6cadcb76570b4bbmg";
        hash = "sha256-NtpuwyKNWP0gknCpQO/zc6b+YQFTjkDeGwRzwTz9Lfw=";
        name = "mahoyo-alice-house-table.jpeg";
      })
      (fromNet {
        url = "http://cache.typemoon.com/images/ib4bf865d7c85d4ccdab28dda13fa1cdemg";
        hash = "sha256-oF8f/Hw4x+aJlC9TnwPsBfazNIoLkLmZWXfgcQCiJRc=";
        name = "mahoyo-misakicho.jpeg";
      })
      (fromNet {
        url = "https://mahoyo-movie.com/assets/img/kv/poster_pc.jpg";
        hash = "sha256-9IBC76e19zuteN6J/rOP7nWJfdpBOeyCGTC+vkeYMtQ=";
        name = "mahoyo-movie-poster.jpg";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/69000196
        url = "https://i.pximg.net/img-original/img/2018/05/31/00/00/03/69000196_p0.png";
        hash = "sha256-5J6LE3PaUX26veB34p/MK0+0EO3F2iJq1Zyo1B5qal4=";
        name = "fgo-mash.png";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/100387114
        url = "https://i.pximg.net/img-original/img/2022/08/11/00/00/31/100387114_p0.jpg";
        hash = "sha256-vkfMLxZxmdSdIMQ0aSYp+b/LEP2RRSKMUBfjPStcDCE=";
        name = "fgo-lady-avalon-kashia.jpg";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/84632644
        url = "https://i.pximg.net/img-original/img/2020/09/27/00/00/04/84632644_p0.jpg";
        hash = "sha256-i9yEo54lOp/yQ8roYlfZO5arYVASskWJnizwwbriFdQ=";
        name = "fgo-lady-avalon-kumokoneko.jpg";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/117984382
        url = "https://i.pximg.net/img-original/img/2024/04/19/23/53/23/117984382_p0.png";
        hash = "sha256-TMaWK8G3J5eFWymPF/5n7m8eIB+STjgCFg+IF7xZOJw=";
        name = "fgo-lady-avalon-fujinariibuki.png";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/85764500
        url = "https://i.pximg.net/img-original/img/2020/11/19/14/35/51/85764500_p0.jpg";
        hash = "sha256-ee+s31IYTk5KxVr8aZ6Z+O8PvcBPoMPkgnbrNraW93M=";
        name = "fgo-lady-avalon-elsa.jpg";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/100507843
        url = "https://i.pximg.net/img-original/img/2022/08/15/19/10/47/100507843_p0.png";
        hash = "sha256-Y1y4P+Q11X7G8A2C1b49lUA1ybjgI5O8U8HFuRPXojk=";
        name = "fgo-lady-avalon-yagi.png";
        crop = "3016x2500+0+0";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/111741898
        url = "https://i.pximg.net/img-original/img/2023/09/15/19/57/57/111741898_p0.jpg";
        hash = "sha256-6MObeoL+1OGMZC1CotqtquDPXV6QBjv3Mmn0VJP1KcY=";
        name = "fgo-lady-avalon-oz-0.jpg";
        crop = "1005x600+0+0";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/111741898
        url = "https://i.pximg.net/img-original/img/2023/09/15/19/57/57/111741898_p2.jpg";
        hash = "sha256-GJQM7reBGAusM5YE+DgJghPYcP7BCIKLt0YkIMSBJEE=";
        name = "fgo-lady-avalon-oz-2.jpg";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/111741898
        url = "https://i.pximg.net/img-original/img/2023/09/15/19/57/57/111741898_p3.jpg";
        hash = "sha256-/5tzTRZu60hbxv6k6iXFarRUQrLf114J2xG+6oqytJM=";
        name = "fgo-lady-avalon-oz-3.jpg";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/112421957
        url = "https://i.pximg.net/img-original/img/2023/10/10/00/42/55/112421957_p0.jpg";
        hash = "sha256-bR4Ojkwu3GEPG95lSYzpG/SwVjCNLr6hzKpRK88A+zw=";
        name = "fgo-lady-avalon-MNe.jpg";
        crop = "3201x2833+0+0";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/133296630
        url = "https://i.pximg.net/img-original/img/2025/07/30/22/15/37/133296630_p0.jpg";
        hash = "sha256-sIu+l8dvcQKR+AvC+s8kmSghYvyALxuhpP4TyF+QHWs=";
        name = "fgo-hope-of-avalon.jpg";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/119815075
        url = "https://i.pximg.net/img-original/img/2024/06/20/22/01/20/119815075_p0.png";
        hash = "sha256-pN2RoG+MYfeJQqdFQXbjRuJHQ180NrB0VMQ8d068kuQ=";
        name = "fgo-medousa.png";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/99310092
        url = "https://i.pximg.net/img-original/img/2022/06/26/10/49/49/99310092_p0.png";
        hash = "sha256-PaNM6aHKVhrgXuwF5vDntsl2vrTw5C/c1wd2xa1NImU=";
        name = "fgo-avalon-le-fae.png";
      })
      (fromNet {
        # https://www.pixiv.net/artworks/125400285
        url = "https://i.pximg.net/img-original/img/2024/12/22/00/01/09/125400285_p0.png";
        hash = "sha256-rmO5JLKh403r2EDS0t/Pdz0ozdy6WF4tMPXoo07ldP4=";
        name = "fgo-morgan-reluvy.png";
      })
      (fromNet {
        url = "https://i.pximg.net/img-original/img/2019/11/15/20/54/22/77828922_p0.jpg";
        hash = "sha256-madMzxWaPVzpdc0iWyLD20krFguVG48GGKwkaRan0D4=";
        name = "fgo-scathach.jpg";
        crop = "3507x2000+0+0";
      })
      (fromNet {
        # https://x.com/kousaki_r/status/1577255417662812160/photo/1
        url = "https://pbs.twimg.com/media/FeOJWRvakAASHHX?format=jpg&name=orig";
        hash = "sha256-eNhibI2s2TdoLVcCmiNHZ4yN0WjZO8wSSIQbd8/m0gI=";
        name = "fgo-lady-avalon-kosaki.jpg";
        crop = "760x650+0+0";
      })
    ]
    ++ (lib.pipe ./wallpapers [
      builtins.readDir
      (lib.filterAttrs (_: v: v == "regular"))
      lib.attrNames
      (map (v: lib.path.append ./wallpapers v))
      (map (path: fromLocal { inherit path; }))
    ]);
in
pkgs.callPackage (
  {
    lib,
    stdenvNoCC,
    fetchurl,
  }:
  let
    fromNet =
      {
        url,
        name,
        hash,
        crop ? null,
      }:
      rec {
        src =
          let
            fetchArgs = {
              inherit url hash;
            }
            // lib.optionalAttrs (lib.strings.hasInfix "/i.pximg.net/" url) {
              curlOptsList = [
                "-H"
                "Referer:https://app-api.pixiv.net/"
              ];
            };
          in
          fetchurl fetchArgs;
        builder =
          if crop == null then
            "cp ${src} $out/${name}"
          else
            "${lib.getExe pkgs.imagemagick} ${src} -crop ${crop} $out/${name}";
      };
    fromLocal =
      { path }:
      rec {
        src =
          if lib.isPath path then
            path
          else if lib.isString path then
            builtins.path {
              name = path;
              path = ./.;
            }
          else
            throw "`path` must be path or string: ${path}";
        builder = "${lib.getExe' pkgs.coreutils "base64"} --decode ${src} > $out/${baseNameOf path}";
      };
  in
  let
    imagePkgs = images { inherit fromNet fromLocal; };
    builderScript = [
      "mkdir -p $out/"
    ]
    ++ (map (v: v.builder) imagePkgs);
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
