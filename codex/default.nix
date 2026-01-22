{
  codex,
  fetchFromGitHub,
  rustPlatform,
  lib,
  nix-update-script,
}:
let
  version = "0.88.0";
  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-Ff6Ut1GwRPd2oB4/YojKgS/CYMG0TVizXOHKfpKClqY=";
  };
in
codex.overrideAttrs (previousAttrs: {
  inherit version src;
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "codex-${version}-vendor";
    sourceRoot = "${src.name}/codex-rs";
    hash = "sha256-eLao+Jaq7+Bu9QNHDJYD3zX2BQvlX/BSTYr4gpCD++Q=";
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
