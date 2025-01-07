{ pkgs }:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs) fetchpatch;
  inherit (pkgs.lib) warn;

  base-emacs = pkgs.emacs30.override {
    withSQLite3 = true;
    withWebP = true;
    withImageMagick = true;
    # have to force this; lib.version check wrong or because emacsGit?
    withTreeSitter = true;
  };

  emacsPlusPatches = [
    # Fix OS window role so that yabai can pick up Emacs
    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
      sha256 = "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
    })

    # Add setting to enable rounded window with no decoration (still
    # have to alter default-frame-alist)
    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/round-undecorated-frame.patch";
      sha256 = "uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
     })

    # Make Emacs aware of OS-level light/dark mode
    # https://github.com/d12frosted/homebrew-emacs-plus#system-appearance-change
    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/system-appearance.patch";
      sha256 = "3QLq91AQ6E921/W9nfDjdOUWR8YVsqBAT/W9c1woqAw=";
    })
  ];
in
if isDarwin then
  base-emacs.overrideAttrs (prev: {
    patches = (prev.patches or [ ]) ++ emacsPlusPatches;
  })
else
  throw "emacs-plus only work on darwin systems"
