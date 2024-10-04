{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "inyourface";
  version = "";
  src = fetchurl {
    url = "https://bluebanana-software.com/iyf/InYourFace.zip";
    hash = "sha256-mS4OsMkDYFsavtYWHtCQrq3XjX9/qhFeI/eL+hZIOak=";
  };
  meta = {
    description = "In Your Face blocks your screen just in time for the meeting.";
    homepage = "https://www.inyourface.app/";
    license = lib.licenses.unfree;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wjh.io";
      }
    ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "InYourFace.app";
  };
in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = with pkgs; [ unzip ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';
}
