{
  pkgs,
  edition,
  ...
}:
let
  sources = (builtins.fromJSON (builtins.readFile ./sources.json));
  build = import ./build.nix;
in
pkgs.callPackage build {
  pname = "${edition}-darwin";
  inherit (sources.${edition}) version url hash;
}
