## This is a copy of https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/cl/claude-code/package.nix so that I can keep it up to date.
{
  pkgs,
  fetchzip,
}:
pkgs.claude-code.overrideAttrs (previousAttrs: rec {
  version = "2.0.29";
  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-6YN0iSX05S+CqZ4NCDM1D+vGlLNV29NpPaVd31JN/u4=";
  };
})
