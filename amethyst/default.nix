{ pkgs }:
let
  inherit (pkgs)
    stdenv
    fetchurl
    lib
    nix-update-script
    ;
  pname = "amethyst";
  version = "0.23.1";
  src = fetchurl {
    url = "https://github.com/ianyh/Amethyst/releases/download/v${version}/Amethyst.zip";
    hash = "sha256-uMgz/+AFhQdaimk1wTzyoNWZG8Xm5vXjgJoftf0sZ6M=";
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
  passthru.updateScript = nix-update-script { };
}
