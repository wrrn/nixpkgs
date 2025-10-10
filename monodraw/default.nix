{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "monodraw";
  version = "1.7.1";
  src = fetchurl {
    url = "https://updates.helftone.com/monodraw/downloads/monodraw-latest.dmg";
    hash = "sha256-0JsDfBYxpgb6jjeM2DjehZL0nTz7F1NckFSh1ko5m6c=";
  };
  meta = {
    description = "ASCII art editor designed for the Mac";
    homepage = "https://monodraw.helftone.com/";
    license = lib.licenses.unfree;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wjh.io";
      }
    ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "Monodraw.app";
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
