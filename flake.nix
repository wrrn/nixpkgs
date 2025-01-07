{
  description = "A collection of nixpkgs that couldn't be found";
  inputs = {
    # Official flakes
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }@inputs:
    let
      inherit (flake-utils.lib) system;
      allPackages = pkgs: rec {
        emacs-plus = pkgs.callPackage ./emacs { };
        emacs-plus-client = pkgs.callPackage ./emacsclient { emacsPkg = emacs-plus; };
        little-snitch = pkgs.callPackage ./little-snitch { };
        amethyst = pkgs.callPackage ./amethyst { };
        dash-docs = pkgs.callPackage ./dash-docs { };
        alfred-mac = pkgs.callPackage ./alfred-mac { };
        inyourface = pkgs.callPackage ./inyourface { };
        monodraw = pkgs.callPackage ./monodraw { };
        hammerspoon = pkgs.callPackage ./hammerspoon { };
        firefox-darwin = pkgs.callPackage ./firefox-darwin { edition = "firefox"; };
        firefox-devedition-darwin = pkgs.callPackage ./firefox-darwin { edition = "firefox-devedition"; };
        librewolf-darwin = pkgs.callPackage ./firefox-darwin {
          edition = "librewolf-${pkgs.hostPlatform.darwinArch}";
        };
      };
    in
    {
      packages = {
        aarch64-darwin =
          let
            pkgs = import nixpkgs {
              system = system.aarch64-darwin;
              config.allowUnfree = true;
            };
          in
          allPackages pkgs;
      };

      overlays.macApps = (final: prev: allPackages final);

      devShells = flake-utils.lib.eachDefaultSystemPassThrough (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          ${system}.default = pkgs.mkShell {
            packages = [
              pkgs.gnumake
              pkgs.jq
              pkgs.coreutils-full
            ];
          };
        }
      );
    };

}
