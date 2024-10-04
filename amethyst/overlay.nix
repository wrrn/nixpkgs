# Add amethyst to nixpkgs
final: prev:
{
  amethyst = import ./default.nix {pkgs = prev};
}
