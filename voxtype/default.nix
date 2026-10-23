{
  lib,
  stdenv,
  runCommand,
  python3,
  rustPlatform,
  symlinkJoin,
  makeWrapper,
  cmake,
  pkg-config,
  clang,
  llvmPackages,
  git,
  alsa-lib,
  openssl,
  onnxruntime,
  # runtime deps
  wtype,
  dotool,
  wl-clipboard,
  ydotool,
  xdotool,
  xclip,
  libnotify,
  pciutils,
  # the voxtype flake input's source tree
  src,
}:

let
  # voxtype's Cargo.toml carries an optional `openvino-genai` dependency pinned
  # to a [patch.crates-io] git fork. `importCargoLock` vendors every git source
  # in the lockfile regardless of which features are enabled, and the cargo git
  # fetcher hard-codes `fetchSubmodules = true`. openvino-rs vendors
  # openvinotoolkit/openvino + openvino.genai, which recurse into 39 submodules
  # across ~40 repos (877 MB) -- a fixed-output derivation fragile enough that
  # it hashes differently on different machines.
  #
  # We never enable the `openvino-whisper` feature, and even when enabled the
  # crate uses `runtime-linking` (dlopens libopenvino_genai.so) so none of those
  # submodules are ever compiled. Strip the dependency so the lockfile has no
  # git sources at all and the 877 MB fetch disappears.
  #
  # Drop this once intel/openvino-rs#196 merges and voxtype removes the patch.
  patchedSrc = runCommand "voxtype-src-no-openvino" {
    inherit src;
    nativeBuildInputs = [ python3 ];
  } ''
    cp -r "$src" "$out"
    chmod -R u+w "$out"

    python3 - "$out" <<'PY'
    import re, sys, pathlib

    root = pathlib.Path(sys.argv[1])

    toml = (root / "Cargo.toml").read_text()
    out, in_patch = [], False
    for line in toml.splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            in_patch = stripped == "[patch.crates-io]"
        if in_patch:
            continue
        if stripped.startswith("openvino-genai ="):
            continue
        if stripped.startswith("openvino-whisper ="):
            continue
        out.append(line)
    toml = "".join(out)
    live = [l for l in toml.splitlines() if "openvino-genai" in l and not l.lstrip().startswith("#")]
    assert not live, f"Cargo.toml still references openvino-genai: {live}"
    (root / "Cargo.toml").write_text(toml)

    lock = (root / "Cargo.lock").read_text()
    blocks = lock.split("[[package]]")
    kept = [blocks[0]] + [
        b for b in blocks[1:]
        if not re.match(r'\nname = "openvino-(finder|genai|genai-sys|sys)"\n', b)
    ]
    lock = "[[package]]".join(kept)
    lock = lock.replace(' "openvino-genai",\n', "")
    assert "openvino" not in lock, "Cargo.lock still references openvino"
    (root / "Cargo.lock").write_text(lock)
    PY
  '';

  runtimeDeps = [
    wtype
    dotool
    wl-clipboard
    ydotool
    xdotool
    xclip
    libnotify
    pciutils
  ];

  cargoToml = builtins.fromTOML (builtins.readFile "${src}/Cargo.toml");

  unwrapped = rustPlatform.buildRustPackage {
    pname = "voxtype-onnx";
    inherit (cargoToml.package) version;

    src = patchedSrc;

    cargoDeps = rustPlatform.importCargoLock {
      lockFile = "${patchedSrc}/Cargo.lock";
      # No outputHashes: with openvino-rs gone the lockfile has no git sources.
    };

    nativeBuildInputs = [
      cmake
      pkg-config
      clang
      llvmPackages.libclang
      git # whisper.cpp cmake wants it
    ];

    buildInputs = [
      alsa-lib
      openssl
      onnxruntime
    ];

    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
    ORT_LIB_LOCATION = "${onnxruntime}/lib";

    buildFeatures = [
      "parakeet-load-dynamic"
      "moonshine"
      "sensevoice"
      "paraformer"
      "dolphin"
      "omnilingual"
      "cohere"
    ];

    RUSTFLAGS = lib.optionalString (stdenv.hostPlatform.system == "x86_64-linux") "-C target-cpu=x86-64-v3";

    preBuild = ''
      export CMAKE_BUILD_PARALLEL_LEVEL=$NIX_BUILD_CORES
    '';

    postInstall = ''
      install -Dm644 packaging/completions/voxtype.bash $out/share/bash-completion/completions/voxtype
      install -Dm644 packaging/completions/voxtype.zsh $out/share/zsh/site-functions/_voxtype
      install -Dm644 packaging/completions/voxtype.fish $out/share/fish/vendor_completions.d/voxtype.fish
      install -Dm644 config/default.toml $out/share/voxtype/default-config.toml
    '';

    meta = {
      description = "Push-to-talk voice-to-text for Linux (ONNX variant, openvino-rs stripped)";
      homepage = "https://voxtype.io";
      license = lib.licenses.mit;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "voxtype";
    };
  };

  libExt = if stdenv.hostPlatform.isDarwin then "dylib" else "so";
in
symlinkJoin {
  name = "voxtype-onnx-wrapped-${unwrapped.version}";
  paths = [ unwrapped ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/voxtype \
      --prefix PATH : ${lib.makeBinPath runtimeDeps} \
      --set ORT_DYLIB_PATH "${onnxruntime}/lib/libonnxruntime.${libExt}" \
      --prefix LD_LIBRARY_PATH : "${onnxruntime}/lib"
  '';
  inherit (unwrapped) meta;
  passthru = { inherit unwrapped patchedSrc; };
}
