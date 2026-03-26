{
  lib,
  codex,
  fetchurl,
  makeWrapper,

  # Runtime dependencies
  bubblewrap,
  python3,
}:
let
  pythonWithPyYAML = python3.withPackages (ps: [ ps.pyyaml ]);
in
codex.overrideAttrs (previousAttrs: {
  RUSTY_V8_ARCHIVE = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v146.4.0/librusty_v8_release_x86_64-unknown-linux-gnu.a.gz";
    hash = "sha256-5ktNmeSuKTouhGJEqJuAF4uhA4LBP7WRwfppaPUpEVM=";
  };

  nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ makeWrapper ];

  postFixup = (previousAttrs.postFixup or "") + ''
    wrapProgram $out/bin/codex --prefix-each PATH : ${
      lib.makeBinPath [
        pythonWithPyYAML
        bubblewrap
      ]
    }
  '';
})
