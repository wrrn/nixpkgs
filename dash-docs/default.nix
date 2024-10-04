{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "dash-docs";
  version = "7";
  src = fetchurl {
    url = "https://newyork.kapeli.com/downloads/v${version}/Dash.zip";
    hash = "sha256-pqUzcNUP8v3ls68BIzWXggXgUVe1wc/bN5BtXqKHXM4==";
  };
  meta = {
    description = "Dash is an API Documentation Browser and Code Snippet Manager.";
    homepage = "https://kapeli.com/dash";
    license = lib.licenses.unfree;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wjh.io";
      }
    ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "Dash.app";
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
# Add amethyst to nixpkgs
final: prev:
{
  amethyst = import ./amethyst.nix {pkgs = prev};
}
