{ pkgs, ... }:
let
  sping-package =
    { fetchFromGitHub }:
    pkgs.rustPlatform.buildRustPackage rec {
      pname = "sping";
      version = "v1.8.0";

      src = fetchFromGitHub {
        owner = "LambdaBytes";
        repo = "sping";
        rev = version;
        hash = "sha256-NX+yc4nB7vq4iWNRGtZ104zZb7BAEXRJOnFe8+dRAs0=";
      };

      cargoHash = "sha256-biMAoz+6pcPkvpKVitA5UFjMz4rjE0ZQUaptJEMEm0U=";
    };
in
{
  nixpkgs.overlays = [
    (_: _: { sping = pkgs.callPackage sping-package { }; })
  ];
}
