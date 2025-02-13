{
  pkgs,
}:
let
  inherit (pkgs) stdenv fetchurl lib;
  pname = "little snitch";
  version = "6.2";
  src = fetchurl {
    url = "https://www.obdev.at/downloads/littlesnitch/LittleSnitch-${version}.dmg";
    hash = "sha256-vYQQ2DyDew3eNjvPP6LpmvBF7npq9ta7pxlsbaRjfLI=";
  };
  meta = {
    # This is an MacOS App, so it won't work anywhere else.
    broken = !stdenv.hostPlatform.isDarwin;
    description = "Little Snitch is a host-based application firewall for macOS.";
    homepage = "https://www.obdev.at/products/littlesnitch";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wjh.io";
      }
    ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "Little Snitch.app";
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
