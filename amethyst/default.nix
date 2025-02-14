{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "amethyst";
  version = "0.22.0";
  src = fetchurl {
    url = "https://github.com/ianyh/Amethyst/releases/download/v${version}/Amethyst.zip";
    hash = "sha256-3J2uMWEywD7Fp/+QdnFk+EEKlOLTJ/G1JaOekPb9kP4=";
  };
  meta = {
    description = "Tiling window manager for macOS along the lines of xmonad.";
    homepage = "https://ianyh.com/amethyst/";
    license = lib.licenses.mit;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wrrn.org";
      }
    ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "Amethyst.App";
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
