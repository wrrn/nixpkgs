{
  lib,
  stdenv,
  bun,
  makeWrapper,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "Foo-x";
    repo = "jw";
    rev = "11942a7e05a110e74bb2b802254c08e191997a14";
    hash = "sha256-bR+HvYVS1PRO12I+6nlqWp/qlNORZ+17Ov3vxZpBJZw=";
  };
  packageMeta = lib.importJSON "${src}/package.json";
  pname = packageMeta.name;
  version = packageMeta.version;
  cliPath = "$out/lib/${pname}/src/index.ts";
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bun ];

  dontBuild = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${pname} $out/bin
    cp -R src $out/lib/${pname}/

    makeWrapper ${bun}/bin/bun $out/bin/${pname} \
      --add-flags "${cliPath}"

    runHook postInstall
  '';

  meta = with lib; {
    description = packageMeta.description;
    homepage = "https://github.com/foo-x/jw";
    license = licenses.mit;
    mainProgram = pname;
    platforms = platforms.unix;
  };
}
