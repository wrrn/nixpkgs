{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "alfred-mac";
  version = "5.6_2290";
  src = fetchurl {
    url = "https://cachefly.alfredapp.com/Alfred_${version}.dmg";
    hash = "sha256-ZF1iM2U4Mf1ME97C7cp+L2kTcOMome330MLLGFl0dBE=";
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

  dontPatchShebangs = true; # Alfred reports that it's broken if the shebangs are patched.
  nativeBuildInputs = with pkgs; [
    undmg
  ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';
}
