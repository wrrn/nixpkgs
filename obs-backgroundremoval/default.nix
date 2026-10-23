{
  pkgs,
  stdenv,
  fetchFromGitHub,
  lib,

  ## Build tools
  cmake,
  ninja,
  pkg-config,

  ## Dependencies
  obs-studio,
  onnxruntime-openvino,
  opencv4,
  curl,
  simde,
  libglvnd, # GLES2 headers (equivalent to libgles2-mesa-dev)
  qt6,

  nix-update-script,
}:
let
  version = "1.5.0";
  src = fetchFromGitHub {
    owner = "royshil";
    repo = "obs-backgroundremoval";
    rev = version;
    hash = "sha256-ekZMiKl68r576v/tXvu5eMgDTaE7QAaIHa+I/GqIxBA=";
  };
in
stdenv.mkDerivation {
  inherit version src;
  pname = "obs-backgroundremoval";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    obs-studio
    onnxruntime-openvino
    onnxruntime-openvino.dev
    opencv4
    curl
    curl.dev
    simde
    libglvnd.dev # GLES2 headers (equivalent to libgles2-mesa-dev)
    qt6.qtbase
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    # Disable vcpkg; use nixpkgs dependencies instead
    "-DVCPKG_TARGET_TRIPLET="
    # Don't treat warnings as errors in the nix build
    "-DCMAKE_COMPILE_WARNING_AS_ERROR=OFF"
  ];
}
