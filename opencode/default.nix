{ opencode, fetchFromGitHub }:
opencode.overrideAttrs (previousAttrs: rec {
  version = "1.1.6";
  src = fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${version}";
    hash = "sha256-uNeje6WZ/FJVOtxdTdWXbWhPl7BwMws+7/Iz2Hz/stw=";
  };
})
