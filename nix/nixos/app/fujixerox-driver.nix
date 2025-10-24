{
  stdenv,
  lib,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  cups,
}:
let
  debPlatform =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "amd64"
    else
      throw "Unsupported system: ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation rec {
  pname = "fxlinuxprint";
  version = "1.1.4-3";

  src = fetchurl {
    url = "https://www.fujifilm.com/fb/sync/pub/exe/docuprint/p450d/fflinuxprint_${version}_${debPlatform}.deb";
    hash = "sha256-oi6p4e9Uigz0TbEcmloDhv3qU98Ou1qqdorGY3942uM=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];
  buildInputs = [ cups ];

  # sourceRoot = ".";
  unpackCmd = "dpkg-deb -x $curSrc extracted/";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    # mv etc $out
    mv usr/lib $out

    mkdir -p $out/share/cups/model
    mv usr/share/ppd/fujifilm/* $out/share/cups/model
  '';

  meta = with lib; {
    description = "Fuji Xerox Linux Printer Driver";
    homepage = "https://www.fujifilm.com/fb/support/printer/ap7_cp4422";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
