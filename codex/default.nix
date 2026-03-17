{
  codex,
  fetchFromGitHub,
  rustPlatform,
  lib,
  libcap,
  nix-update-script,
  stdenv,
  python3,
  mold,
  clang,
}:
let
  version = "0.115.0";
  pythonWithPyYAML = python3.withPackages (ps: [ ps.pyyaml ]);
  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-8l5OZQS6L1uhVpqZZGx2O3Xt6qTaTAYDR5XWOydTVuQ=";
  };
in
codex.overrideAttrs (previousAttrs: {
  inherit version src;
  env = (previousAttrs.env or { }) // {
    CARGO_PROFILE_RELEASE_LTO = "thin";
    CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "16";
    CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "clang";
    RUSTFLAGS = "-C link-arg=-fuse-ld=${mold}/bin/mold";

  };

  nativeBuildInputs = (previousAttrs.nativeBuildInputs or [ ]) ++ [
    mold
    clang
  ];

  buildInputs =
    (previousAttrs.buildInputs or [ ]) ++ lib.optionals stdenv.hostPlatform.isLinux [ libcap ];
  postFixup = (previousAttrs.postFixup or "") + ''
    wrapProgram $out/bin/codex --prefix PATH : ${lib.makeBinPath [ pythonWithPyYAML ]}
  '';
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

  cargoBuildFlags = (previousAttrs.cargoBuildFlags or [ ]) ++ [ "--timings" ];

  postInstall = (previousAttrs.postInstall or "") + ''
    cp target/cargo-timings/cargo-timing.html $out/cargo-timing.html
  '';

  passthru = previousAttrs.passthru or { } // {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "rust-v(.*)"
      ];
    };
  };
})
