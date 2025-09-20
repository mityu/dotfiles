{ pkgs, ... }:
let
  awesome-deficient-pkg =
    {
      lib,
      lua,
      stdenvNoCC,
      fetchFromGitHub,
    }:
    stdenvNoCC.mkDerivation rec {
      pname = "awesome-deficient";
      version = "22ad2bea198f0c231afac0b7197d9b4eb6d80da3";

      src = fetchFromGitHub {
        owner = "deficient";
        repo = "deficient";
        rev = version;
        hash = "sha256-INZx053s/PIbRw3mLCobybVuuJENjhyxnsv3LDzi/AI=";
      };

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/lua/${lua.luaversion}/
        cp -r . $out/lib/lua/${lua.luaversion}/deficient/
        runHook postInstall
      '';

      meta = with lib; {
        license = licenses.unlicense;
        homepage = "https://github.com/deficient/deficient";
        platforms = platforms.all;
      };
    };
in
pkgs.callPackage awesome-deficient-pkg { }
