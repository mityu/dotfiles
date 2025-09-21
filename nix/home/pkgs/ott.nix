{ opam-nix }:
let
  inherit (opam-nix.lib.x86_64-linux) queryToScope;
  scope = queryToScope { } {
    ott = "*";
    ocaml-base-compiler = "*";
  };
  overlay = final: prev: {
    ott = prev.ott.overrideAttrs (_: {
      doNixSupport = false;
      removeOcamlReferences = true;
    });
  };
in
(scope.overrideScope overlay).ott
