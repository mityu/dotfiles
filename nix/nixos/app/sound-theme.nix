{ pkgs, lib, ... }:
let
  sound-theme-pkg =
    { stdenv }:
    stdenv.mkDerivation {
      pname = "sound-theme";
      version = "none";

      nativeBuildInputs = [
        pkgs.ocaml
        pkgs.yaru-theme
        pkgs.sound-theme-freedesktop
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
          override_stereo_dir='${pkgs.yaru-theme}/share/sounds/Yaru/stereo'

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
