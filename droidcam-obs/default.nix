{ stdenv
, fetchFromGitHub
, obs-studio-plugins
}:

(obs-studio-plugins.droidcam-obs.override {
  inherit stdenv;
}).overrideAttrs (oldAttrs: {
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "dev47apps";
    repo = "droidcam-obs-plugin";
    tag = "2.5.0";
    sha256 = "sha256-JPAQoGZFzTIdBQ7GpCPaYUVPkkcBdCRFkVPU+nyRa7Q=";
  };

  patches = [];
})
