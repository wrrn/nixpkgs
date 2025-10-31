{
  pkgs,
  lib,
  stdenv,
}:
pkgs.sbcl.overrideAttrs (previousAttrs: {
  disabledTestFiles =
    previousAttrs.disabledTestFiles
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # This test has a gotcha on Darwin which originally showed up in
      # 57b36ea5c83a1841b174ec6cd5e423439fe9d7a0, and later again around Oct
      # 2025 in staging.  The test wants a clean environment (using
      # run-program, akin to fork & execve), but darwin keeps injecting this
      # envvar:
      #
      #   __CF_USER_TEXT_ENCODING=0x15F:0:0
      #
      # It’s not clear to maintainers where the problem lies exactly, but
      # removing the test at least fixes the build and unblocks others.
      #
      # see:
      # - https://github.com/NixOS/nixpkgs/pull/359214
      # - https://github.com/NixOS/nixpkgs/pull/453099
      "run-program.test.sh"
    ];

})
