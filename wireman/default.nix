{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wireman";
  version = "0.2.7";
  src = fetchFromGitHub {
    owner = "preiter93";
    repo = "wireman";
    rev = finalAttrs.version;
    hash = "sha256-/htx1KKWxnWS64Irz0D8hH/8R3Us1GlINlsm3SIgR9A=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-A/kzyoLtFxd0I8MprR5ifp6p1a2SpBSnbWN/fcqicJs=";

  meta = with lib; {
    description = "A gRPC client for the terminal";
    homepage = "https://github.com/preiter93/wireman";
    changelog = "https://github.com/preiter93/wireman/releases/tag/${version}";
    license = with licenses; [
      mit
    ];
    maintainers = [ ];
    mainProgram = "wireman";
    platforms = lib.platforms.all;
  };
})
