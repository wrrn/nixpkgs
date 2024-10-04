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
          emacs-plus = import ./emacs/emacs-plus.nix { inherit pkgs; };
          little-snitch = import ./little-snitch { inherit pkgs; };
        };
      };
      overlays = {
        emacs = import ./emacs/overlay.nix;
        little-snitch = import ./little-snitch/overlay.nix;
      };
    };
}
