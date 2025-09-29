{ opam-nix, system }:
let
  inherit (opam-nix.lib.${system}) queryToScope;
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
