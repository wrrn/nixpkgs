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
        amethyst = pkgs.callPackage ./amethyst { };
        emacs-plus = pkgs.callPackage ./emacs { };
        emacs-plus-client = pkgs.callPackage ./emacsclient { emacsPkg = emacs-plus; };
        firefox-devedition-darwin = pkgs.callPackage ./firefox-darwin { edition = "firefox-devedition"; };
        claude-code = pkgs.callPackage ./claude-code { };
        ghostty = pkgs.callPackage ./ghostty { };
        hammerspoon = pkgs.callPackage ./hammerspoon { };
        librewolf-darwin = pkgs.callPackage ./firefox-darwin {
          edition = "librewolf-${pkgs.hostPlatform.darwinArch}";
        };
        mongodb-atlas-cli = pkgs.callPackage ./mongodb-atlas-cli { };
        mongosh = pkgs.callPackage ./mongosh { };
        monodraw = pkgs.callPackage ./monodraw { };
        shortcat = pkgs.callPackage ./shortcat { };
        wireman = pkgs.callPackage ./wireman { };
        yaak = pkgs.callPackage ./yaak { };
        zen-browser = pkgs.callPackage ./zenbrowser { };
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

      overlays.macApps = (
        final: prev: {
          wrrn = allPackages final;
        }
      );

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
              pkgs.nix-update
            ];
          };
        }
      );
    };

}
