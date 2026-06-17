{
  lib,
  stdenv,
  symlinkJoin,
  makeWrapper,
  onnxruntime,
  pciutils,
  libnotify,
  xclip,
  xdotool,
  ydotool,
  wl-clipboard,
  dotool,
  wtype,
  inputs,
}:

let
  system = stdenv.hostPlatform.system;

  # Upstream's `onnx` output omits the `cohere` (and `soniox`) Cargo features,
  # so the Cohere engine is described but not compiled in. Rebuild the unwrapped
  # ONNX binary with `cohere` added. All of cohere's deps (onnx-common, half,
  # tokenizers) are already pulled in by the other ONNX engines, so this adds no
  # new crates and needs no cargoHash/lock changes.
  voxFeatures = [
    "parakeet-load-dynamic"
    "moonshine"
    "sensevoice"
    "paraformer"
    "dolphin"
    "omnilingual"
    "cohere"
  ];

  unwrapped = inputs.voxtype.packages.${system}.voxtype-onnx-unwrapped.overrideAttrs (old: {
    buildFeatures = voxFeatures;
    cargoBuildFeatures = voxFeatures;
    cargoCheckFeatures = voxFeatures;
  });
in
symlinkJoin {
  name = "voxtype-onnx-cohere-${unwrapped.version}";
  paths = [ unwrapped ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/voxtype \
      --prefix PATH : ${
        lib.makeBinPath [
          pciutils
          libnotify
          xclip
          xdotool
          ydotool
          wl-clipboard
          dotool
          wtype
        ]
      } \
      --set ORT_DYLIB_PATH "${onnxruntime}/lib/libonnxruntime.so" \
      --prefix LD_LIBRARY_PATH : "${onnxruntime}/lib"
  '';
  inherit (unwrapped) meta;
}
