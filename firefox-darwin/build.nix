{
  pkgs,
  pname,
  version,
  url,
  hash,
}:
let
  inherit (pkgs) stdenv fetchurl lib;
  src = fetchurl {
    inherit url hash;
  };
  meta = {
    description = "Mozilla Firefox, free web browser (binary package)";
    homepage = "https://www.mozilla.org/en-US/firefox";
    license = lib.licenses.mpl20;
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
    runHook preInstall
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
    runHook postInstall
  '';
}
