{
  pkgs,
  fetchFromGitHub,
}:
pkgs.mongodb-atlas-cli.overrideAttrs (previousAttrs: rec {
  version = "1.48.0";

  src = fetchFromGitHub {
    owner = "mongodb";
    repo = "mongodb-atlas-cli";
    tag = "atlascli/v${version}";
    hash = "sha256-xdsW1REvd6yIsFO9j4t7Ydb9eVt1a3I3TMBYw5eeYXI=";
  };

  vendorHash = "sha256-Qwk4iVFvNGyam3QNJSuwCHD0BiqPIGV7qj3HfUzJNsQ=";
})
