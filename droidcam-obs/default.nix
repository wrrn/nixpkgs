{ stdenv
, fetchFromGitHub
, obs-studio-plugins
}:

(obs-studio-plugins.droidcam-obs.override {
  inherit stdenv;
}).overrideAttrs (finalAttrs: oldAttrs: {
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "dev47apps";
    repo = "droidcam-obs-plugin";
    tag = finalAttrs.version;
    sha256 = "sha256-T7CQrjQK5OV1bgqa2il9snsK7nScuVhV06NuX2SoIeI=";
  };

  patches = [];
})
