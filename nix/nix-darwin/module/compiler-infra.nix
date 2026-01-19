{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.compiler-infra;
in
{
  options.compiler-infra = {
    enable = lib.mkEnableOption "compiler-infra";

    accessibleGlobally = lib.mkOption {
      type = lib.types.bool;
      description = ''
        If this option is enabled, the installed libraries will be
        accessible when compiling some program using externally managed
        compilers.

        This is experimentall and may break your environment.
      '';
      default = false;
      example = lib.literalExpression "true";
    };

    apple-sdk = lib.mkPackageOption pkgs "apple-sdk" { };
    xcbuild = lib.mkPackageOption pkgs "xcbuild" { };

    libs = lib.mkOption {
      type = with lib.types; listOf package;
      description = "Extra libraries to install.";
      default = [ ];
      example = lib.literalExpression "[ pkgs.libiconv ]";
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [
        cfg.apple-sdk
        cfg.xcbuild
      ]
      ++ cfg.libs;
    }
    // lib.optionalAttrs cfg.accessibleGlobally {
      pathsToLink = [
        "/include"
        "/lib"
        "/share/pkgconfig"
      ];

      variables =
        let
          sdkroot = cfg.apple-sdk.sdkroot;
          pkgpaths = [ "${sdkroot}/usr" ] ++ cfg.libs;
          targetHost = lib.replaceString "-" "_" pkgs.stdenv.hostPlatform.config;
        in
        {
          # Set some environmental paths to make it be able to compile programs by
          # externally managed build tools.
          SDKROOT = sdkroot;
          DEVELOPER_DIR = "${cfg.apple-sdk}";
          LIBRARY_PATH = lib.makeLibraryPath pkgpaths;
          CPATH = lib.makeIncludePath pkgpaths;
          DYLD_FRAMEWORK_PATH = "${sdkroot}/System/Library/Frameworks";
          NIX_LDFLAGS = "-L/run/current-system/sw/lib";
          NIX_CFLAGS_COMPILE = "-I/run/current-system/sw/include";
          PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
          "NIX_BINTOOLS_WRAPPER_TARGET_HOST_${targetHost}" = "1";
          # TODO: NIXPKGS_CMAKE_PREFIX_PATH
        };
    };
  };
}
