{
  pkgs,
}:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "little snitch";
  version = "6.1.1";
  src = fetchurl {
    url = "https://www.obdev.at/downloads/littlesnitch/LittleSnitch-6.1.1.dmg";
    hash = "sha256-nizzwmfGLfYBkP4YrjWBXvaQ4uKmztOBk3SFImht24w=";
  };
  meta = {
    # This is an MacOS App, so it won't work anywhere else.
    broken = !stdenv.hostPlatform.isDarwin;
    description = "Little Snitch is a host-based application firewall for macOS";
    homepage = "https://www.obdev.at/products/littlesnitch";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    # license = lib.licenses.unfree;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wjh.io";
      }
    ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "little snitch";
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

  # Little Snitch is notarized.
  dontFixup = true;
}
