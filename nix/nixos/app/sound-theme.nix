{ pkgs, lib, ... }:
let
  yaru-sound-theme-derivation =
    { stdenv, fetchFromGitHub }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "yaru";
      version = "25.10.3";

      src = fetchFromGitHub {
        owner = "ubuntu";
        repo = "yaru";
        rev = finalAttrs.version;
        hash = "sha256-3cSVPObfmr62S6yTD2c8AO3s7lxb9KFVuYSydTIJ1jE=";
      };

      dontConfigure = true;
      dontBuild = true;
      dontDropIconThemeCache = true;

      installPhase = ''
        runHook preInstall
        mkdir -p "$out/share/sounds/Yaru/"
        cp -r "$src/sounds/src/stereo" "$out/share/sounds/Yaru/"
        runHook postInstall
      '';
    });
  yaru-sound-theme = pkgs.callPackage yaru-sound-theme-derivation { };
  sound-theme-pkg =
    { stdenv }:
    stdenv.mkDerivation {
      pname = "sound-theme";
      version = "none";

      nativeBuildInputs = [
        pkgs.ocaml
        pkgs.sound-theme-freedesktop
        yaru-sound-theme
      ];

      builder =
        let
          ocaml = lib.getExe' pkgs.ocaml "ocaml";
          installation-finder = pkgs.writeTextFile {
            name = "list-installation.ml";
            text = ''
              open List
              open Filename
              open Sys

              let main () =
                let base_files_dir = argv.(1) in
                let extension_files_dir = argv.(2) in
                let extension_files = extension_files_dir
                  |> readdir
                  |> Array.to_list
                  |> map (concat extension_files_dir)
                in
                let base_files =
                  let extension_file_names = map (fun v -> remove_extension @@ basename v) extension_files in
                  base_files_dir
                  |> readdir
                  |> Array.to_list
                  |> filter (fun v -> Bool.not @@ mem (remove_extension v) extension_file_names)
                  |> map (concat base_files_dir)
                in
                iter print_endline (rev_append base_files extension_files);;

              main ();;
            '';
          };
          index-theme = pkgs.writeTextFile {
            name = "index.theme";
            text = lib.generators.toINI { } {
              "Sound Theme" = {
                Name = "Default";
                Directories = "stereo";
              };
              "stereo" = {
                OutputProfile = "stereo";
              };
            };
          };
        in
        pkgs.writeShellScript "merge-sound-theme" ''
          install_stereo_dir="$out/share/sounds/freedesktop-and-yaru/stereo"
          base_stereo_dir='${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo'
          override_stereo_dir='${yaru-sound-theme}/share/sounds/Yaru/stereo'

          mkdir -p $install_stereo_dir
          cp ${index-theme} $install_stereo_dir/../index.theme
          ${ocaml} ${installation-finder} "$base_stereo_dir" "$override_stereo_dir" | \
            xargs -I{} cp -p {} $install_stereo_dir
        '';
    };
in
{
  xdg.sounds.enable = false;
  environment.systemPackages = [ (pkgs.callPackage sound-theme-pkg { }) ];
  environment.pathsToLink = [ "/share/sounds" ];
}
