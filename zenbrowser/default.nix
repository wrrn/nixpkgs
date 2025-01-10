{ lib, pkgs }:
let
  inherit (pkgs)
    stdenv
    stdenvNoCC
    fetchurl
    lib
    ;
  pname = "zen-browser";
  version = "1.6b";
  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/latest/download/zen.macos-aarch64.dmg";
    hash = "sha256-ktJqRFwGzmZzR7hDzYY83tLZX93k53IQn8vrurKchrc=";
  };
  meta = {
    description = "🌀 Experience tranquillity while browsing the web without people tracking you!";
    homepage = "https://zen-browser.app/";
    license = lib.licenses.mpl20;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wrrn.org";
      }
    ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "Zen Browser.App";
  };
in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = with pkgs; [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';
}
