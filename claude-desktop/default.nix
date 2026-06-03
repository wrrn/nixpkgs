{ pkgs
, inputs
, claude-desktop-pkgs
}:

########################################################################
# WORKAROUND: Local patch for upstream issue #677
#
#   https://github.com/aaddrick/claude-desktop-debian/issues/677
#
# In Claude Desktop 1.10628.0 the addTrustedFolder log statement is now
# emitted as a comma-operator expression ending with `),` instead of a
# standalone statement ending with `);`. The upstream patch hardcodes
# `);` and aborts the build with "[FAIL] addTrustedFolder anchor not
# found".
#
# TODO: Remove this override once the upstream repo merges a fix.
########################################################################

builtins.trace
  "WARNING: Local workaround active for claude-desktop (upstream issue #677). Check https://github.com/aaddrick/claude-desktop-debian/issues/677 and remove when fixed."
  (let
    patchedSrc = pkgs.runCommand "claude-desktop-src-patched" {} ''
      cp -r ${inputs.claude-desktop} $out
      chmod -R +w $out
      sed -i 's|\\`);|\\`),|' $out/scripts/patches/config.sh
    '';

    patched = claude-desktop-pkgs.claude-desktop.overrideAttrs (oldAttrs: {
      buildPhase = ''
        runHook preBuild

        export HOME=$TMPDIR
        cp $src Claude-Setup.exe
        bash ${patchedSrc}/build.sh \
          --exe "$(pwd)/Claude-Setup.exe" \
          --source-dir "${patchedSrc}" \
          --node-pty-dir "${pkgs.callPackage "${inputs.claude-desktop}/nix/node-pty.nix" {}}/lib/node_modules/node-pty" \
          --build nix \
          --clean no

        runHook postBuild
      '';
    });
  in
    claude-desktop-pkgs.claude-desktop-fhs.override { claude-desktop = patched; })
