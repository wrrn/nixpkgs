{
  pkgs,
  fetchFromGitHub,
  lib,
}:
pkgs.mongodb-atlas-cli.overrideAttrs (previousAttrs: rec {
  version = "1.48.0";

  src = fetchFromGitHub {
    owner = "mongodb";
    repo = "mongodb-atlas-cli";
    tag = "atlascli/v${version}";
    hash = "sha256-xdsW1REvd6yIsFO9j4t7Ydb9eVt1a3I3TMBYw5eeYXI=";
  };

  # Have to set this because it's set the generated derivation.
  ldflags = [
    "-s"
    "-w"
    "-X github.com/mongodb/mongodb-atlas-cli/atlascli/internal/version.GitCommit=${src.rev}"
    "-X github.com/mongodb/mongodb-atlas-cli/atlascli/internal/version.Version=v${version}"
  ];

  vendorHash = "sha256-Qwk4iVFvNGyam3QNJSuwCHD0BiqPIGV7qj3HfUzJNsQ=";
})
