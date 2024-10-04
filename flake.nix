{
  description = "A collection of nixpkgs that couldn't be found";
  inputs = {
    # Official flakes
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
    }@inputs:
    let
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        allowUnfree = true;
      };
    in
    {
      packages = {
        aarch64-darwin = {
          emacs-plus = import ./emacs { inherit pkgs; };
          little-snitch = import ./little-snitch { inherit pkgs; };
          amethyst = import ./amethyst { inherit pkgs; };
          dash-docs = import ./dash-docs { inherit pkgs; };
          alfred-mac = import ./alfred-mac { inherit pkgs; };
        };
      };
      overlay.macApps = (
        final: prev:
        (builtins.mapAttrs (
          name: value: import "./${name}" { pkgs = prev; }
        ) self.packages.${builtins.currentSystem})
      );

    };
}
