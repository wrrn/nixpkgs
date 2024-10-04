# Use emacs-plus patches on osx


# relevant links:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/emacs/generic.nix
# https://github.com/nix-community/emacs-overlay/blob/master/overlays/emacs.nix
# https://github.com/d12frosted/homebrew-emacs-plus/tree/master/patches/emacs-30
# https://github.com/noctuid/dotfiles/tree/master/nix/overlays/emacs.nix

final: prev:
{
  # configuration shared for all systems
  emacs-plus = import ./emacs-plus.nix {nixpkgs = prev};
}
