{
  pkgs,
  fetchFromGitHub,
  lib,
}:
pkgs.mongosh.overrideAttrs (previousAttrs: rec {
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "mongodb-js";
    repo = "mongosh";
    tag = "v${version}";
    hash = "sha256-0rol41XNdpfVRGY8KXFmQ0GHg5QqgnCaF21ZFyxfKeQ=";
  };

  patches = [
    (builtins.elemAt previousAttrs.patches 0)
  ];
  npmDepsHash = "sha256-rB8Dg4nQb5zbEKpCx0kN4f3sC8zDY4wrmOp5jdAufoY=";
  npmDeps = pkgs.fetchNpmDeps {
    inherit src;
    name = "${previousAttrs.pname}-${version}-npm-deps";
    hash = npmDepsHash;
  };

})
