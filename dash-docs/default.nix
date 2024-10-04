{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "dash-docs";
  version = "5.5.1";
  src = fetchurl {
    url = "https://cachefly.alfredapp.com/Alfred_${version}_2273.dmg";
    hash = "sha256-wo8oNaytz07f05aZZW2X7ckmVBiDc1sM0kL6dfLZbHY=";
  };
  meta = {
    description = "Alfred is an app for macOS to boost your efficiency with hotkeys, keywords, text expansion and more.";
    homepage = "https://kapeli.com/dash";
    # license = lib.licenses.unfree;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wjh.io";
      }
    ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "Alfred.app";
  };
in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = with pkgs; [
    unzip
    undmg
  ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';
}
