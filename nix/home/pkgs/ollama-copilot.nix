{ pkgs, lib, ... }:
let
  ollama-copilot-pkg =
    { fetchFromGitHub }:
    pkgs.buildGoModule (finalAttrs: {
      pname = "ollama-copilot";
      version = "885044c987271ac763420d288edc3e49934ae5c6";

      src = fetchFromGitHub {
        owner = "bernardo-bruning";
        repo = "ollama-copilot";
        rev = finalAttrs.version;
        hash = "sha256-d/j2sRqrOx8eX520nneGTyL0Q0XIVH2UbYef42cuPbU=";
      };

      vendorHash = "sha256-g27MqS3qk67sve/jexd07zZVLR+aZOslXrXKjk9BWtk=";

      buildInputs = [ pkgs.ollama ];

      meta = {
        description = "Proxy that allows you to use ollama as a copilot like Github copilot";
        homepage = "https://github.com/bernardo-bruning/ollama-copilot";
        license = lib.licenses.mit;
      };
    });
in
pkgs.callPackage ollama-copilot-pkg { }
