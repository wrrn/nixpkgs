# Add amethyst to nixpkgs
final: prev:
{
  dash-docs = import ./default.nix {pkgs = prev};
}
