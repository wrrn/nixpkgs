{
  obs-studio-plugins,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
let
  version = "1.3.6";
  src = fetchFromGitHub {
    owner = "occ-ai";
    repo = "obs-backgroundremoval";
    rev = version;
    hash = "sha256-QoC9/HkwOXMoFNvcOxQkGCLLAJmsja801LKCNT9O9T0=";
  };
in
obs-studio-plugins.obs-backgroundremoval.overrideAttrs (previousAttrs: {
  inherit version src;
})
