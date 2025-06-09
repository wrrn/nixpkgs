{ pkgs }:
let
  inherit (pkgs)
    stdenv
    fetchurl
    lib
    nix-update-script
    ;
  pname = "yaak";
  version = "2025.3.1";
  src = fetchurl {
    url = "https://github.com/mountain-loop/yaak/releases/download/v${version}/Yaak_${version}_aarch64.dmg";
    hash = "sha256-mJ0At+dFUyG+F1WiupR/DopZfbKKXJNMKf1LlalVR9U=";
  };
  meta = {
    description = "Yaak is a desktop API client for interacting with REST, GraphQL, Server Sent Events (SSE), WebSocket, and gRPC APIs.";
    homepage = "https://yaak.app/";
    license = lib.licenses.mit;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wrrn.org";
      }
    ];
    platforms = [ "aarch64-darwin" ];
    # mainProgram = "Yaak.app";
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
