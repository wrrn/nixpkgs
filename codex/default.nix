{
  codex,
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "0.86.0";
  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-sypqDp67nMnxSmdUs2W8TCmfe2Ye9jO3vXLOpNeqjlI=";
  };
in
codex.overrideAttrs (previousAttrs: {
  inherit version src;
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "codex-${version}-vendor";
    sourceRoot = "${src.name}/codex-rs";
    hash = "sha256-Ryr5mFc+StT1d+jBtRsrOzMtyEJf7W1HbMbnC84ps4s=";
  };
})
