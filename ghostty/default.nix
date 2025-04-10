{ pkgs }:
let
  linux = pkgs.ghostty;
  darwin =
    let
      inherit (pkgs)
        stdenv
        stdenvNoCC
        fetchurl
        lib
        nix-update-script
        ;
      pname = "ghostty";
      version = "1.1.3";
      src = fetchurl {
        url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
        hash = "sha256-ZOUUGI9UlZjxZtbctvjfKfMz6VTigXKikB6piKFPJkc=";
      };
      meta = {
        description = "Ghostty is a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration.";
        homepage = "https://ghostty.org/";
        license = lib.licenses.mit;
        maintainers = [
          {
            name = "Wrrn";
            email = "nix@wrrn.org";
          }
        ];
        platforms = [ "aarch64-darwin" ];
        mainProgram = "Ghostty.App";
      };
    in
    stdenv.mkDerivation {
      inherit
        pname
        version
        src
        meta
        ;

      nativeBuildInputs = with pkgs; [ _7zz ];

      sourceRoot = ".";

      installPhase = ''
        mkdir -p $out/Applications
        cp -r *.app $out/Applications
      '';

      passthru.updateScript = nix-update-script { };
    };
in
if pkgs.stdenvNoCC.hostPlatform.isDarwin then darwin else linux
