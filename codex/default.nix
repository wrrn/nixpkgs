{
  lib,
  codex,
  fetchurl,
  makeWrapper,
  stdenv,

  # Runtime dependencies
  bubblewrap,
  python3,
}:
let
  pythonWithPyYAML = python3.withPackages (ps: [ ps.pyyaml ]);
in
codex.overrideAttrs (previousAttrs: {

  nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ makeWrapper ];

  ## Warning we are overwriting codex's postFixup. If we are missing things this is why.
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/codex \
      --prefix PATH : ${
        lib.makeBinPath [
          bubblewrap
          pythonWithPyYAML
        ]
      }
  '';
})
