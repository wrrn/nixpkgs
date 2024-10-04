{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "amethyst";
  version = "0.21.2";
  src = fetchurl {
    url = "https://github.com/ianyh/Amethyst/releases/download/v${version}/Amethyst.zip";
    hash = "sha256-pqUzcNUP8v3ls68BIzWXggXgUVe1wc/bN5BtXqKHXM4==";
  };
  meta = {
    description = "Tiling window manager for macOS along the lines of xmonad.";
    homepage = "https://ianyh.com/amethyst/";
    license = lib.licenses.mit;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wjh.io";
      }
    ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "Little Snitch.App";
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
