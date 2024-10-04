{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "hammerspoon";
  version = "1.0.0";
  src = fetchurl {
    url = "https://github.com/Hammerspoon/hammerspoon/releases/download/${version}/Hammerspoon-${version}.zip";
    hash = "sha256-wo8oNaytz07f05aZZW2X7ckmVBiDc1sM0kL6dfLZbHY=";
  };
  meta = {

    description = "Staggeringly powerful macOS desktop automation with Lua";
    homepage = "https://www.hammerspoon.org";
    license = lib.licenses.mit;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wjh.io";
      }
    ];
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "Hammerspoon.app";
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
    runHook preInstall
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
    runHook postInstall
  '';
}
