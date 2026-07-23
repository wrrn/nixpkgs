{
  description = "A collection of nixpkgs that couldn't be found";
  inputs = {
    # Official flakes
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "unstable";
    };

    lan-mouse = {
      url = "github:feschber/lan-mouse";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    voxtype = {
      url = "github:peteonrails/voxtype";
      inputs.nixpkgs.follows = "unstable";
    };

    octotype = {
      url = "github:mahlquistj/octotype/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gittype = {
      url = "github:unhappychoice/gittype";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      unstable,
      flake-utils,
      claude-desktop,
      lan-mouse,
      llm-agents,
      octotype,
      gittype,
      voxtype,
      ...
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

      packages =
        { pkgs, pkgs-unstable }:
        let
          inherit (pkgs.stdenv.hostPlatform) system;
          llm-agents = inputs.llm-agents.packages.${system};
          claude-desktop-pkgs = inputs.claude-desktop.packages.${system};
          lan-mouse-pkgs = inputs.lan-mouse.packages.${system};
        in
        rec {
          claude-code = llm-agents.claude-code;
          claude-desktop = claude-desktop-pkgs.claude-desktop-fhs;
          codex = pkgs.callPackage ./codex {
            codex = llm-agents.codex;
          };
          handy = llm-agents.handy;
          pi = llm-agents.pi;

          jw = pkgs.callPackage ./jw { };
          lan-mouse = lan-mouse-pkgs.default;
          mongodb-atlas-cli = pkgs.callPackage ./mongodb-atlas-cli { };
          mongosh = pkgs.callPackage ./mongosh { };
          obs-plugin-droidcam-obs = pkgs-unstable.callPackage ./droidcam-obs {
            stdenv = pkgs.stdenv;
          };
          obs-plugin-backgroundremoval = pkgs-unstable.callPackage ./obs-backgroundremoval {
            inherit onnxruntime-openvino;
          };
          obs-plugin-backgroundremoval-lite = pkgs-unstable.callPackage ./obs-live-backgroundremoval-lite { };

          onnxruntime-openvino = pkgs-unstable.callPackage ./onnxruntime-openvino { };

          pdfbook2 = pkgs.callPackage ./pdfbook2 { };
          sbcl = pkgs.callPackage ./sbcl { };
          warm-burnout = pkgs.callPackage ./warm-burnout { };
          voxtype = pkgs-unstable.callPackage ./voxtype { inherit inputs; };

          # cider = pkgs-unstable.callPackage ./cider-2 { };
          # gittype = inputs.gittype.packages.${pkgs.system}.default;
          # octotype = inputs.octotype.packages.${pkgs.system}.octotype;
        };

      allPackages =
        { pkgs, pkgs-unstable }: (darwinPackages pkgs) // (packages { inherit pkgs pkgs-unstable; });
    in
    {
      packages = {
        aarch64-darwin =
          let
            pkgs = import nixpkgs {
              system = system.aarch64-darwin;
              config.allowUnfree = true;
            };
            pkgs-unstable = import unstable {
              system = system.aarch64-darwin;
              config.allowUnfree = true;
            };
          in
          (darwinPackages pkgs) // (packages { inherit pkgs pkgs-unstable; });
        x86_64-linux =
          let
            pkgs = import nixpkgs {
              system = system.x86_64-linux;
              config.allowUnfree = true;
            };
            pkgs-unstable = import unstable {
              system = system.x86_64-linux;
              config.allowUnfree = true;
            };

          in
          packages { inherit pkgs pkgs-unstable; };
      };

      overlays = {
        default = (
          final: prev: {
            wrrn = allPackages {
              pkgs = final;
              pkgs-unstable = import unstable {
                system = final.stdenv.system;
                config.allowUnfree = true;
              };
            };
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

      homeManagerModules = {
        lan-mouse = import ./lan-mouse/hm-module.nix inputs.lan-mouse;
      };

      checks.x86_64-linux.lan-mouse-module =
        (inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = system.x86_64-linux; };
          modules = [
            (import ./lan-mouse/hm-module.nix inputs.lan-mouse)
            {
              home.username = "test";
              home.homeDirectory = "/home/test";
              home.stateVersion = "24.11";
              programs.lan-mouse.enable = true;
            }
          ];
        }).activationPackage;
    };

}
