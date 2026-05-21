{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

let
  version = "1.8.0";
in
stdenvNoCC.mkDerivation {
  pname = "warm-burnout";
  inherit version;

  src = fetchFromGitHub {
    owner = "felipefdl";
    repo = "warm-burnout";
    rev = "main";
    hash = "sha256-EtAPdh+voNf+z4dDq38jKwbniEJu2htlQNYaqH3lcQI=";
  };

  dontBuild = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall

    base=$out/share/warm-burnout

    for platform in alacritty bat emacs eza ghostty helix iterm2 nvim obsidian starship tmux vim warp wezterm xcode zed zellij zsh; do
      if [ -d "$platform" ]; then
        mkdir -p "$base/$platform"
        cp -r "$platform"/. "$base/$platform/"
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "WCAG-audited warm syntax color theme for 20+ editors and terminals";
    homepage = "https://github.com/felipefdl/warm-burnout";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [
      {
        name = "Wrrn";
        email = "nix@wrrn.org";
      }
    ];
  };
}
