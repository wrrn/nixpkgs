{
  lib,
  stdenv,
  onnxruntime,
  openvino,
}:

# onnxruntime built with the OpenVINO execution provider so that downstream
# consumers (e.g. obs-backgroundremoval) can offload inference to an Intel GPU.
# On non-Linux platforms this falls back to the unmodified onnxruntime since
# openvino is broken on aarch64-darwin in nixpkgs and there is no Intel GPU to
# target on Apple Silicon anyway.
if !stdenv.hostPlatform.isLinux then
  onnxruntime
else
  onnxruntime.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ openvino ];
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-Donnxruntime_USE_OPENVINO=ON"
    ];
  })
