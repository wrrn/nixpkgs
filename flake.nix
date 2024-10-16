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
      allPackages = pkgs: {
        emacs-plus = pkgs.callPackage ./emacs { };
        little-snitch = pkgs.callPackage ./little-snitch { };
        amethyst = pkgs.callPackage ./amethyst { };
        dash-docs = pkgs.callPackage ./dash-docs { };
        alfred-mac = pkgs.callPackage ./alfred-mac { };
        inyourface = pkgs.callPackage ./inyourface { };
        monodraw = pkgs.callPackage ./monodraw { };
        hammerspoon = pkgs.callPackage ./hammerspoon { };
        firefox-darwin = pkgs.callPackage ./firefox-darwin { edition = "firefox"; };
        firefox-devedition-darwin = pkgs.callPackage ./firefox-darwin { edition = "firefox-devedition"; };
        bartender = pkgs.bartender;
      };
    in
    {
      packages = {
        aarch64-darwin =
          let
            pkgs = import nixpkgs {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
          in
          allPackages pkgs;
      };

      overlay.macApps = (final: prev: allPackages final);
    };
}
