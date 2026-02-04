{
  codex,
  version,

  clang,
  cmake,
  gitMinimal,
  installShellFiles,
  makeBinaryWrapper,

  libclang,
  openssl,
  stdenv,
}:
codex.overrideAttrs (previousAttrs: {
  inherit version;
  __intentionallyOverridingVersion = true;

  nativeBuildInputs = (previousAttrs.nativeBuildInputs or [ ]) ++ [
    clang
    cmake
    gitMinimal
    installShellFiles
    makeBinaryWrapper
  ];

  buildInputs = (previousAttrs.buildInputs or [ ]) ++ [
    libclang
    openssl
  ];

  # BoringSSL builds with -Werror; glibc fortified headers trigger stringop-overflow.
  CFLAGS = (previousAttrs.CFLAGS or "") + " -Wno-error=stringop-overflow";
  CXXFLAGS = (previousAttrs.CXXFLAGS or "") + " -Wno-error=stringop-overflow";

  LIBCLANG_PATH = "${libclang.lib}/lib";
  BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${stdenv.cc.libc_dev}/include";
})
