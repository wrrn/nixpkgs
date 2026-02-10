{
  lib,
  pkgs,
  fetchFromGitHub,

  # Build deps
  cmake,
  pkg-config,
  ninja,

  # Runtime/Build deps
  libGL,
  qt6Packages,
  qt6,
  simde,
  ncnn,
  obs-studio,
  curl,
  fmt,
  ...
}:
let
  version = "3.9.1";
  src = fetchFromGitHub {
    owner = "kaito-tokyo";
    repo = "live-backgroundremoval-lite";
    rev = version;
    hash = "sha256-mnryKubIgoaAZQEMOMAnkgjJ0j0jIZy8Y3GFPbF0wOE=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "obs-live-backgroundremoval-lite";
  inherit version src;
  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    obs-studio
    qt6.qtbase
    qt6.qtsvg
    ncnn
    libGL
    simde
    curl
    fmt
  ];

  dontWrapQtApps = true;

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DBUILD_TESTING=false"
  ];

  meta = {
    description = "A high-performance, crash-resistant OBS plugin for real-time background removal. Optimized for minimal CPU/GPU usage without a green screen. ";
    homepage = "https://kaito-tokyo.github.io/live-backgroundremoval-lite/";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
