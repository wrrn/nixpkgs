{ pkgs }:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs) fetchpatch;
  inherit (pkgs.lib) warn;

  base-emacs = pkgs.emacs29.override {
    withSQLite3 = true;
    withWebP = true;
    withImageMagick = true;
    # have to force this; lib.version check wrong or because emacsGit?
    withTreeSitter = true;
  };

  emacsPlusPatches = [
    # Don't raise another frame when closing a frame
    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/no-frame-refocus-cocoa.patch";
      sha256 = "QLGplGoRpM4qgrIAJIbVJJsa4xj34axwT3LiWt++j/c=";
    })

    # Fix OS window role so that yabai can pick up Emacs
    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
      sha256 = "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
    })

    # Use poll instead of select to get file descriptors
    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/poll.patch";
      sha256 = "jN9MlD8/ZrnLuP2/HUXXEVVd6A+aRZNYFdZF8ReJGfY=";
    })

    # Add setting to enable rounded window with no decoration (still
    # have to alter default-frame-alist)
    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/round-undecorated-frame.patch";
      sha256 = "uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
    })

    # Make Emacs aware of OS-level light/dark mode
    # https://github.com/d12frosted/homebrew-emacs-plus#system-appearance-change
    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/system-appearance.patch";
      sha256 = "oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
    })
  ];
in
if isDarwin then
  base-emacs.overrideAttrs (prev: {
    patches = (prev.patches or [ ]) ++ emacsPlusPatches;
  })
else
  throw "emacs-plus only work on darwin systems"
