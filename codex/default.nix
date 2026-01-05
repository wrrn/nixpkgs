{
  codex,
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "0.79.0";
  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-fp/R/F0LcFLHfSNUW4pO2EG2ICce5vzxsOBYrm2tyaA=";
  };
in
codex.overrideAttrs (previousAttrs: {
  inherit version src;
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "codex-${version}-vendor";
    sourceRoot = "${src.name}/codex-rs";
    hash = "sha256-qCf8kJ2AuPfpykNiF2KNJqOs+Vq+BQHgMseqPtiGiz0=";
  };
})
