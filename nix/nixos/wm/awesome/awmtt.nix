{ pkgs, ... }:
let
  awesome-awmtt-pkg =
    {
      lib,
      lua,
      stdenvNoCC,
      fetchFromGitHub,
      makeWrapper,
    }:
    luaModules:
    let
      mkSearchPathAdder =
        modules:
        let
          mkSearchPath = module: place: "${module}/${place}/lua/${lua.luaversion}";

          # The last space is necessary because awmtt concatenates arguments
          # given via "-a" without any white spaces.
          mkFlag = module: place: "--add-flags '-a \"--search ${mkSearchPath module place} \"'";
          flags = builtins.concatMap (
            v:
            builtins.map (mkFlag v) [
              "lib"
              "share"
            ]
          ) modules;
        in
        builtins.toString flags;
    in
    stdenvNoCC.mkDerivation rec {
      pname = "awesome-awmtt";
      version = "92ababc7616bff1a7ac0a8e75e0d20a37c1e551e";

      src = fetchFromGitHub {
        owner = "gmdfalk";
        repo = "awmtt";
        rev = version;
        hash = "sha256-3IpCuLIdN4t4FzFSHAlJ9FW9Y8UcWIqXG9DfiAwZoMY=";
      };

      nativeBuildInputs = [ makeWrapper ];

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp ./awmtt.sh $out/bin/.awmtt-wrapped
        chmod u+x $out/bin/.awmtt-wrapped
        makeWrapper "$out/bin/.awmtt-wrapped" "$out/bin/awmtt" \
          ${mkSearchPathAdder luaModules}
        runHook postInstall
      '';

      meta = with lib; {
        homepage = "https://github.com/gmdfalk/awmtt";
        license = licenses.mit;
        platforms = platforms.linux;
      };
    };
in
pkgs.callPackage awesome-awmtt-pkg { }
