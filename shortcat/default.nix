{
  lib,
  stdenv,
  fetchurl,
  unzip,
  ...
}:

stdenv.mkDerivation rec {
  pname = "shortcat";
  version = "0.12.0";

  src = fetchurl {
    url = "https://files.shortcat.app/releases/v${version}/Shortcat.zip";
    sha256 = "sha256-lEcmvqWEToPuoVFsHyeFfjQzIq4MhSNQMkG9QWvbHQA=";
  };

  sourceRoot = "Shortcat.app";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications/Shortcat.app
    cp -R . $out/Applications/Shortcat.app
  '';

  meta = with lib; {
    description = "Manipulate macOS masterfully, minus the mouse";
    homepage = "https://shortcat.app/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
    maintainers = [ ];
    license = licenses.unfreeRedistributable;
  };
}
