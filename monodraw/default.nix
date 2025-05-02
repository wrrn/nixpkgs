{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "monodraw";
  version = "1.7";
  src = fetchurl {
    url = "https://updates.helftone.com/monodraw/downloads/monodraw-latest.dmg";
    hash = "sha256-4e72KVYeoM8S608VtDbrOxowk9IN0Q5bVdeuV95CFGQ=";
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
