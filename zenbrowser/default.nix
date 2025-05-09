{ lib, pkgs }:
let
  inherit (pkgs)
    stdenv
    stdenvNoCC
    fetchurl
    lib
    nix-update-script
    ;
  pname = "zen-browser";
  version = "1.12.3b";
  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.macos-universal.dmg";
    hash = "sha256-LYU3WIiCeqCezLmES5qPHWD20dkQlBvzXSi80RFWgPU=";
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

  passthru.updateScript = nix-update-script { };
}
