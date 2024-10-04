# Add alfred-mac to nixpkgs
final: prev:
{
  alfred-mac = import ./default.nix {pkgs = prev};
}
