{
  codex,
  fetchFromGitHub,
  rustPlatform,
  lib,
  nix-update-script,
}:
let
  version = "0.95.0";
  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-qJKOk7rk1Uv7BI9pYFp42c5qrelx5TGOUIRIdOhf1Xc=";
  };
in
codex.overrideAttrs (previousAttrs: {
  inherit version src;
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "codex-${version}-vendor";
    sourceRoot = "${src.name}/codex-rs";
    hash = "sha256-vVLMPrZ23n/u6fJQcw6GR4GiyzmMgHvpHFhZZL2CRW4=";
  };

  passthru = previousAttrs.passthru or { } // {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "rust-v(.*)"
      ];
    };
  };
})
