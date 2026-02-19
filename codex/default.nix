{
  codex,
  fetchFromGitHub,
  rustPlatform,
  lib,
  libcap,
  nix-update-script,
  stdenv,
}:
let
  version = "0.104.0";
  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-spWb/msjl9am7E4UkZfEoH0diFbvAfydJKJQM1N1aoI=";
  };
in
codex.overrideAttrs (previousAttrs: {
  inherit version src;
  env = (previousAttrs.env or { }) // {
    CARGO_PROFILE_RELEASE_LTO = "thin";
    CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "16";
  };
  buildInputs = (previousAttrs.buildInputs or [ ]) ++ lib.optionals stdenv.hostPlatform.isLinux [ libcap ];
  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${src}/codex-rs/Cargo.lock";
    outputHashes = {
      "crossterm-0.28.1" = "sha256-6qCtfSMuXACKFb9ATID39XyFDIEMFDmbx6SSmNe+728=";
      "nucleo-0.5.0" = "sha256-Hm4SxtTSBrcWpXrtSqeO0TACbUxq3gizg1zD/6Yw/sI=";
      "ratatui-0.29.0" = "sha256-HBvT5c8GsiCxMffNjJGLmHnvG77A6cqEL+1ARurBXho=";
      "runfiles-0.1.0" = "sha256-uJpVLcQh8wWZA3GPv9D8Nt43EOirajfDJ7eq/FB+tek=";
      "tokio-tungstenite-0.28.0" = "sha256-hJAkvWxDjB9A9GqansahWhTmj/ekcelslLUTtwqI7lw=";
      "tungstenite-0.27.0" = "sha256-AN5wql2X2yJnQ7lnDxpljNw0Jua40GtmT+w3wjER010=";
    };
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
