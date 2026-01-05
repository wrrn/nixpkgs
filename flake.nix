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

    octotype = {
      url = "github:mahlquistj/octotype/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gittype = {
      url = "github:unhappychoice/gittype";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      octotype,
      gittype,
    }@inputs:
    let
      inherit (flake-utils.lib) system;
      darwinPackages = pkgs: rec {
        amethyst = pkgs.callPackage ./amethyst { };
        emacs-plus = pkgs.callPackage ./emacs { };
        emacs-plus-client = pkgs.callPackage ./emacsclient { emacsPkg = emacs-plus; };
        firefox-devedition-darwin = pkgs.callPackage ./firefox-darwin { edition = "firefox-devedition"; };
        librewolf-darwin = pkgs.callPackage ./firefox-darwin {
          edition = "librewolf-${pkgs.hostPlatform.darwinArch}";
        };
        hammerspoon = pkgs.callPackage ./hammerspoon { };
        monodraw = pkgs.callPackage ./monodraw { };
        shortcat = pkgs.callPackage ./shortcat { };
      };

      packages = pkgs: rec {
          claude-code = pkgs.callPackage ./claude-code { };
          mongodb-atlas-cli = pkgs.callPackage ./mongodb-atlas-cli { };
          mongosh = pkgs.callPackage ./mongosh { };
          sbcl = pkgs.callPackage ./sbcl { };
          pdfbook2 = pkgs.callPackage ./pdfbook2 { };
          opencode = pkgs-unstable.callPackage ./opencode { };
          codex = pkgs-unstable.callPackage ./codex { };
          # gittype = inputs.gittype.packages.${pkgs.system}.default;
          # octotype = inputs.octotype.packages.${pkgs.system}.octotype;
        };

      allPackages = pkgs: (darwinPackages pkgs) // (packages pkgs);
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
          (darwinPackages pkgs) // (packages pkgs);
      };

      overlays = {
        default = (
          final: prev: {
            wrrn = allPackages final;
          }
        );

        macApps = (
          final: prev: {
            wrrn = allPackages final;
          }
        );
      };

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
