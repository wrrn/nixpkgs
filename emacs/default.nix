{ pkgs }:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs) fetchpatch;
  inherit (pkgs.lib) warn;

  base-emacs = pkgs.emacs31.override {
    withSQLite3 = true;
    withWebP = true;
    # have to force this; lib.version check wrong or because emacsGit?
    withTreeSitter = true;
  };

  emacsPlusPatches = [
    # Fix OS window role so that yabai can pick up Emacs

    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-31/fix-ns-x-colors.patch";
      sha256 = "oe3DFgEXwp0cZJl+ufWqTonaeWSliikTRsVDNbcy4Yw=";
    })

    # Make Emacs aware of OS-level light/dark mode
    # https://github.com/d12frosted/homebrew-emacs-plus#system-appearance-change
    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-31/system-appearance.patch";
      sha256 = "4+2U+4+2tpuaThNJfZOjy1JPnneGcsoge9r+WpgNDko=";
    })

    # Add setting to enable rounded window with no decoration (still
    # have to alter default-frame-alist)
    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-31/round-undecorated-frame.patch";
      sha256 = "KCMEvJzN1OkwFYoMLpZghvdeoO1Ckcxk3Mo19YAf850=";
    })

    (fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-31/fix-ns-scroll-crash.patch";
      sha256 = "syC9un5Vy1+bmBWIc+TEwTCM/nfPIxd4IhWYdEfP4qE=";
    })

  ];
in
if isDarwin then
  base-emacs.overrideAttrs (prev: {
    patches = (prev.patches or [ ]) ++ emacsPlusPatches;
  })
else
  throw "emacs-plus only work on darwin systems"
