{
  fetchurl,
  appimageTools,
  alsa-lib,
  lib,
  writeShellScriptBin,
}:
let
  version = "0.7.1";
  src = fetchurl {
    url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_${version}_amd64.AppImage";
    hash = "sha256-7IUZZriIVmqf85O49w9tCrTKfQURuAOM+k3sKVyigFk=";
  };
  appimage = appimageTools.wrapType2 {
    pname = "handy-appimage-unwrapped";
    inherit version src;
    extraPkgs = pkgs: with pkgs; [ alsa-lib ];
  };
in
writeShellScriptBin "handy" ''
  export WEBKIT_DISABLE_DMABUF_RENDERER=1
  exec ${appimage}/bin/handy-appimage-unwrapped "$@"
''
