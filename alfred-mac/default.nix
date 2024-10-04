{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "alfred-mac";
  version = "5.5.1";
  src = fetchurl {
    url = "https://cachefly.alfredapp.com/Alfred_${version}_2273.dmg";
    hash = "sha256-BopF9IV/JOpu/aViwV4nDxivlQUZmN+K3+f1/7BaN6M=";
  };
  meta = {
    description = "Alfred is an app for macOS to boost your efficiency with hotkeys, keywords, text expansion and more.";
    homepage = "https://alfredapp.com/";
    license = lib.licenses.unfree;
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
