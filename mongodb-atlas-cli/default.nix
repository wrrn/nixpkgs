{
  pkgs,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
pkgs.mongodb-atlas-cli.overrideAttrs (previousAttrs: rec {
  version = "1.50.0";

  src = fetchFromGitHub {
    owner = "mongodb";
    repo = "mongodb-atlas-cli";
    tag = "atlascli/v${version}";
    hash = "sha256-vo2vfnGKp71S9mVGK5SVi8YqNLjedzfjJhh5uK/pb4E=";
  };

  # Have to set this because it's set the generated derivation.
  ldflags = [
    "-s"
    "-w"
    "-X github.com/mongodb/mongodb-atlas-cli/atlascli/internal/version.GitCommit=${src.rev}"
    "-X github.com/mongodb/mongodb-atlas-cli/atlascli/internal/version.Version=v${version}"
  ];

  vendorHash = "sha256-qcB8Hgp/4kVsEo32E6I4GMSBbRByPTyk3Oas2CpS4Xc=";
})
